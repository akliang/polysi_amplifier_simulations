function [s q S]=loadeldobin(indatfile,paramsmfile)
% LOADELDOBIN reads .bin/.meta files produces by eldobin, and can evaluate the parameter .m-file created by extract_params.sh
%   returns s (column names etc), q (the data), S (params2struct results)
%   $HeadURL: svn://svn.imager.umro/masdax/trunk/circuitsim/2011_medphyspaper/spc_testbenches/spie2016_presentation/octave_scripts/loadeldobin.m $
%   $Id: loadeldobin.m 1765 2016-08-05 15:57:55Z liang $
% Syntax:
%   [s q]   = loadeldobin(indatfile)    % s from indatfile.meta (or indatfile), q from indatfile.bin (the actual data)
%   [s q S] = loadeldobin(indatfile,paramsmfile)   % s and q from indatfile, S from paramsmfile
%   [s q S] = loadeldobin(indatfile)               % will look for a paramsmfile based on indatfile to retrieve S
%   S       = loadeldobin('',paramsmfile)   % reads S from paramsmfile (params2struct replacement)
% Possible indatfile names to be called with:
%  data.dat
%  data.dat.bin
%  data.dat.meta
%  data.dat.thin.bin
% CAREFUL: paramsmfile is EVALUATED, so sourcing a regular matlab script can be dangerous!
% TODO: paramsmfile situation changed, no classic .m-file any more, and extract_params.sh does not create a .m-file

s=[]; q=[]; S={}; % Pre-initialize so that [s q S]=loadeldobin('',paramsmfile); will not throw an error

if ~(isempty(indatfile));

F=indatfile;                   % F="$1"
F=regexprep(F,'\.bin$','');    % F="${F%.bin}"  # Remove .bin  suffix if present
F=regexprep(F,'\.meta$','');   % F="${F%.meta}" # Remove .meta suffix if present
FNT=regexprep(F,'\.thin$',''); % FNT="${F%.thin}" # Filename without .thin, if originally present

tic;fprintf(1,'loadeldobin: Loading %s ...\n', F);

FM=[ FNT '.meta' ];
if ~exist(FM,'file'); % if [ ! -f "$FM" ]; then
	fprintf(1,'Warning: %s does not exist, using %s instead...\n', FM, F );
    FM=F;
end

% grep -B 1 -m 1 -v '^#' "$1" | head -n 1
fid=fopen(FM,'r');
HLINE=[];
while true;
    LINE=strtrim(fgetl(fid));
    if ~isempty(LINE);
        if (LINE(1)=='#');
            HLINE=LINE;
        else
            if (~isempty(HLINE)); break; end
        end
    end
end
fclose(fid);

% sed -r -e 's/[(.]/_/g' -e 's/,[^)]*[)]//g' -e 's/[)]//g' -e 's/^# //'
HLINE=regexprep(HLINE,'^#\s*',''); % Remove leading # and whitespaces
HLINE=regexprep(HLINE,'[(.]','_'); % Replace ( and . with _
HLINE=regexprep(HLINE,'[)]'  ,''); % Remove  )

numcols=0;
while ~isempty(HLINE);
    numcols=numcols+1;
    [ colname HLINE ]=strtok(HLINE); %#ok<STTOK> because octave 3.2 doesn't have textscan. and we need loop anyway
    % textscan and strtok support 'Delimiter','\t'. without it, any whitespace will suffice, which is what we want right now.
    colname=genvarname(colname); % genvarname converts strings into valid variable names,    
    s.(colname)=numcols; % and we make a new field with that name in the strcut s, and give it the column number    
end
s.cols=length(fieldnames(s));

fid=fopen([ F '.bin' ],'r');
[q s.rows]=fread(fid,[s.cols, Inf],'double','ieee-le');
fclose(fid);
s.rows=s.rows/s.cols;
q=q';

%outbin=reshape(outbin,[s.rows s.cols s.sets]);

fprintf(1,'loadeldobin: ...done in %.3f seconds (%d columns, %d rows).\n', toc, s.cols, s.rows);
end; % if ~(isempty(indatfile));


if (nargout>2) || ( (nargout==1) && (isempty(indatfile)) );
  if exist('paramsmfile','var');
      FNT=paramsmfile;
  end
  if exist([ FNT '.meta'], 'file'); FNT=[ FNT '.meta' ]; end
  [FNTdir,FNTbase]=fileparts(FNT); %#ok<ASGLU>
  tic;fprintf(1,'loadeldobin: Evaluating %s ...', FNTbase);
  S=sub_params2struct(FNT);
  if (nargout==1) && (isempty(indatfile));
      s=S;
  end
  fprintf(1,' ...%d fields done in %.1f seconds.\n', length(fieldnames(S)), toc);
end


end

function [ res ] = spiceparamparser( L )
debug=false;
if debug; L, end %#ok<UNRCH>
    % Experimental parser for proper .param separation
    res={};
    ws={ ' ', sprintf('\t') }; % List of white spaces
    ll='';% current VAR=EXPRESSION string
    ps=1; % Parser states: LHE,(=),RHE(w/termchar),INSTR(")
    for cid=1:length(L); C=L(cid);
        stripit=false;
        switch ps
            case 1 % LHE
                switch C
                    case '=', ps=2; whiteok=true; termchar='';
                    case '!', break; % COMMENT starts, ignore the rest of the line
                    case ws,  stripit=true; % don't rely on loader STRTRIM, and any LHE whitespace should be unnecessary
                end
            case 2 % RHE
                switch C
                    case termchar,
                        if termchar==')'; termcount=termcount-1; else termcount=0; end
                        if termchar~=')' || termcount==0; termchar=''; whiteok=false; stripit=true; end
                    case '"',  ps=3; whiteok=false;
                    case '''', if isempty(termchar); termchar=''''; stripit=true; end
                    case '{',  if isempty(termchar); termchar='}';  stripit=true; end
                    case '(',
                        if isempty(termchar) && whiteok;
                            termchar=')'; termcount=1; stripit=true;
                        elseif termchar==')';
                            termcount=termcount+1;
                        end
                    %case '!', % An ! in RHE should never be a comment!
                    %    if isempty(termchar);
                    %        if debug; ll, end %#ok<UNRCH>
                    %        res{end+1}=ll; ll=''; %#ok<AGROW>
                    %        break; % COMMENT starts, ignore the rest of the line
                    %    end
                    case ws,
                        if isempty(termchar) && ~whiteok;
                            if debug; ll, end %#ok<UNRCH>
                            res{end+1}=ll; ll=''; %#ok<AGROW>
                            stripit=true;
                            ps=1;
                        end
                    otherwise, whiteok=false;
                end
            case 3 % INSTR
                if C=='"'; ps=2; end % Any string HAS TO BE terminated by a trailing ".
        end
        if ~stripit; ll=[ ll C ]; end %#ok<AGROW>;
    end
    if debug; ll, end %#ok<UNRCH>
    if ~isempty(ll);
        if ps==1; % still looking for a complete LHE? Then the previous expression isn't nicely quoted. We don't support that right now
%            res{end}=[ res{end} ll ]; % treat is as part of previous expression. Not recommended
           fprintf(2,'LINE: "%s"\n',L);
           fprintf(2,' lhe: "%s"\n',ll);
           error('params2struct: above LINE contains an ambigious expression, consider {} or () to make it non-ambigious');
        else
            res{end+1}=ll;
        end
    end
end

%{
 thoughts on extract_params:
    extract from .cir, .chi, .meta (in ascending order of priority)
    .param in eldo, p-spice(?) and t-spice support space-containing expressions in {}, () or '', strings in ""
    .param par1=a par2=b   ! this is several parameters defined in one line
    .param fun(a)=a^2      ! should become matlab fun=@(a)a^2;
%}

function [ S ] = sub_params2struct( mfile )
% PARAMS2STRUCT evaluates an m-file created by extract_params.sh and returns the results in a structure named S
%   $HeadURL: svn://svn.imager.umro/masdax/trunk/circuitsim/2011_medphyspaper/spc_testbenches/spie2016_presentation/octave_scripts/loadeldobin.m $
%   $Id: loadeldobin.m 1765 2016-08-05 15:57:55Z liang $
   
   SM={};
   %sff=fopen([mfile '.mparams'],'r');
   sff=fopen([mfile ''],'r');
   while ~feof(sff);
        LINE=strtrim(fgets(sff));
        if numel(LINE)>2; 
            %if (LINE(1)>='A'); % avoid any comment lines, line should start with valid character
            %    SETTINGS_MAT{end+1}=LINE; %#ok<AGROW>
            %end
            if       regexp(LINE,'(?i)^#?\s*[0-9]*:*\s*\.PARAM\s+\S+(\([^)]*\))?\s*=');
                LINE=regexprep(LINE,'(?i)^#?\s*[0-9]*:*\s*\.PARAM\s+',''); 
                % This is the right location to handle several parameters defined in one line: .param par1=a par2=b
                %disp(LINE);
                for L=spiceparamparser(LINE); L=L{1}; %#ok<FXSET>
                    SM{end+1}=L; %#ok<AGROW>
                end
            end
        end
   end
   fclose(sff);
   %SM
   % Doing what extract_params.sh did:
   % ! Comments now handled by parser
   %SM=regexprep(SM,{'\s!.*$','\s*$','\s*=\s*'}, {'','','='}); % Remove comments and trim whitespaces at EOL and around =
   SM=regexprep(SM,{'\s+$','\s*=\s*'}, { '', '='}); % Trim whitespaces at EOL and around =.
   % {} now handled by parser, as well as () and ''
   %SM=regexprep(SM,{'={\s*','\s*}$' }, {'=', '' }); % Remove curly braces, but only after = and before EOL ($).
   SM=regexprep(SM, '^([^=]*)=([^"])',  '$1=  $2'); % Distinguish strings from non-strings by adding spaces after first =

   % replace all quantifiers known to spice/eldo: a, f, p, n, u, m, K, MEG, G, T (case-insensitive)
   RE={ '^([^=]*= .*[^a-zA-Z0-9]+[0-9.]+(e[+-]?[0-9]*)?)[Tt][a-zA-Z]*',         '$1e+12';
        '^([^=]*= .*[^a-zA-Z0-9]+[0-9.]+(e[+-]?[0-9]*)?)[Gg][a-zA-Z]*',         '$1e+9' ;
        '^([^=]*= .*[^a-zA-Z0-9]+[0-9.]+(e[+-]?[0-9]*)?)[Mm][Ee][Gg][a-zA-Z]*', '$1e+6' ;
        '^([^=]*= .*[^a-zA-Z0-9]+[0-9.]+(e[+-]?[0-9]*)?)[kK][a-zA-Z]*',         '$1e+3' ;
        '^([^=]*= .*[^a-zA-Z0-9]+[0-9.]+(e[+-]?[0-9]*)?)[mM][a-zA-Z]*',         '$1e-3' ;
        '^([^=]*= .*[^a-zA-Z0-9]+[0-9.]+(e[+-]?[0-9]*)?)[uU][a-zA-Z]*',         '$1e-6' ;
        '^([^=]*= .*[^a-zA-Z0-9]+[0-9.]+(e[+-]?[0-9]*)?)[nN][a-zA-Z]*',         '$1e-9' ;
        '^([^=]*= .*[^a-zA-Z0-9]+[0-9.]+(e[+-]?[0-9]*)?)[pP][a-zA-Z]*',         '$1e-12';
        '^([^=]*= .*[^a-zA-Z0-9]+[0-9.]+(e[+-]?[0-9]*)?)[fF][a-zA-Z]*',         '$1e-15';
        '^([^=]*= .*[^a-zA-Z0-9]+[0-9.]+(e[+-]?[0-9]*)?)[aA][a-zA-Z]*',         '$1e-18';
        '^([^=]*= .*[^a-zA-Z0-9]+[0-9.]+(e[+-]?[0-9]*)?)[a-zA-Z]*', '$1' }; % Last expresion: any remaining character is not a scale factor, so remove it
   SM=regexprep(SM,RE(:,1), RE(:,2) );
   SM=regexprep(SM,'^([^=]*)=  ', '$1='); % Revert the added spaces after = (marking non-strings)
   SM=regexprep(SM,'^([^=]*)(\([^=]*\))=', '$1=@$2'); % Convert functions like .param fun(a)=a^2 to matlab anonymous function: fun=@(a)a^2;
   SM=regexprep(SM,'"', '''');  % Convert " to ' for MATLAB/OCTAVE strings
   %SM=regexprep(SM,{'"','(.)$'}, {'''', '$1;'});  % Convert " to ' and add ; for MATLAB/OCTAVE

   % After each variable assignment, populate S by adding an S.variable=variable;
   EVALSTR=cell2mat(regexprep(SM,'([^=]*)(=.*)',sprintf('$1$2;\nS____S.$1=$1;\n')));

	try
        S=sub_eval(EVALSTR);
	catch %#ok<CTCH> %err  % err commented for octave 3.2 compatibility
        err=lasterror; %#ok<LERR>
        fprintf(2,'%s\n',EVALSTR);  
        fprintf(2,'params2struct: above EVALSTR threw an error upon evaluation!\n');
        fprintf(2,'Now evaluating line by line to find the problem:\n');
        % evalc could provide a nicer workaround for the next line, but not avaiable in octave yet (checked 3.8.1)
        for L=SM; L=[L{1} ';']; disp(L); eval(L); end %#ok<FXSET>. Don't add the ; to L for additional "debug output"
        fprintf(2,'No individual line threw an error. Something unexpected happened, a bug in this function itself?');
        rethrow(err);
	end

   if isempty(S);
       fprintf(2,'%s\n',EVALSTR);
       error('params2struct: above EVALSTR did not yield any fields in S');
   end
end

function [ S ] = sub_eval( EVALSTR )
   % Consider disabling the line below, in case error message below is not the desired behavior?
   S____S={}; % Assign an empty S, to avoid linter message, and to avoid bailing out if parameters are empty?
   eval(EVALSTR);
   S=S____S;
end

