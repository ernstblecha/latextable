function [ s ] = latexTable(tablehead, tabledata, caption, varargin)
%latexTable A function to transform a matrix + tableheading into a beautiful latex table

    nl=sprintf('\n');
    carray=@(s,w){cellstr(char(ones(w,1)*s))'};
    [~, w] = size(tabledata);

    settings = struct('tableformat',['\begin{longtable}{%3$s}' nl...
                                     '\caption{%1$s}\label{%2$s}\\' nl...
                                     '\toprule' nl...
                                     '%4$s%5$s' nl...
                                     '\bottomrule' nl...
                                     '\end{longtable}']...
                      ,'headline',  '\midrule'...
                      ,'linesep', '\hline'...
                      ,'columnsep', ''...
                      ,'leftsep',''...
                      ,'leftheadsep','|'...
                      ,'rightsep',''...
                      ,'lineformat',carray('%3.3f',w)...
                      ,'latexformat',carray('p{2cm}',w)...
                      ,'latexnumberformat',carray('S',w)...
                      );

    switch length(varargin)
        case 0
            label = '';
        case 1
            label = varargin{1};
        case 2
            label = varargin{1};
            if ~isstruct(varargin{2})
                error('invalid settings structure');
            end
            f = fieldnames(varargin{2});
            for i = 1:length(f)
                settings.(f{i}) = varargin{2}.(f{i});
            end
        otherwise
            error('unsupported number of arguments');
    end

    s = latexTableInt(tablehead, tabledata, caption, label, settings);
end

function [ s ] = latexTableInt(tablehead, tabledata, caption, label, settings)
% main code for generation of the table

    m=@(s)strrep(s,'\','\\');
    nl=sprintf('\n');
    tab=sprintf('\t');

    if ~ischar(label)
        error('invalid label');
    end
    if ~ischar(caption)
        error('invalid caption');
    end
    if ~isstruct(settings)
        error('invalid setting structure');
    end

    if ~iscell(tablehead) || length(tablehead) < 0
        error('invalid headings array');
    end

    [h, w] = size(tabledata);
    if length(tablehead) == 2 && iscell(tablehead{1}) && iscell(tablehead{2})

        [hta wta] = size(tablehead{1});
        [htb wtb] = size(tablehead{2});
        if wta == w && hta == 1 && wtb == 1 && htb == h
            tableheadhead = tablehead{1};
            tableheadline = tablehead{2};
        elseif wta == 1 && hta == h && wtb == w && htb == 1
            tableheadhead = tablehead{2};
            tableheadline = tablehead{1};
        elseif wta == 0 && hta == 0 && wtb == 0 && htb == 0
            tableheadhead = {};
            tableheadline = {};
        else
            error('invalid cell array for column headings and line labels');
        end
    elseif length(tablehead) > 0
        [ht wt] = size(tablehead);
        if wt == w && ht == 1
            tableheadhead = tablehead;
            tableheadline = {};
        elseif ht == h && wt == 1
            tableheadhead = {};
            tableheadline = tablehead;
        else
            tableheadhead = {};
            tableheadline = {};
        end
    else
        tableheadhead = {};
        tableheadline = {};
    end

    [~, wh] = size(tableheadhead);
    [hh, ~] = size(tableheadline);

    if length(settings.lineformat) ~= w ||...
       length(settings.latexformat) ~= w ||...
       length(settings.latexnumberformat) ~=w
        error('invalid format cell array');
    end

    if h < 1
        error('no tabledata!');
    end

    seperators = cellstr(char(ones(w,1)*[tab '& ']))';
    seperators{w} = [tab '\\' nl];

    columns = cellstr(strcat(settings.latexnumberformat,settings.columnsep));

    if wh == w
        for i = 1:w
            tableheadhead{i} = sprintf(m('\multicolumn{1}{%s}{%s}'),settings.latexformat{i},tableheadhead{i});
        end
        s = [cell2mat(strcat(tableheadhead,seperators))...
             settings.headline...
            ];
        if hh == h
            s = ['\multicolumn{1}{l}{}&' s];
        end
    else
        s = '';
    end

    if hh == h
        lines = ['l' settings.leftheadsep];
    else
        lines = '';
    end

    columns = [settings.leftsep lines cell2mat(columns) settings.rightsep];



    t='';
    if h > 1
        seperators{w} = [tab m('\\') m(settings.linesep) nl];
        for i=1:h-1
            if hh == h
                line = [m(tableheadline{i}) tab '&'];
            else
                line = '';
            end
            t = strcat(t,...
                sprintf(...
                 sprintf( [nl m('%s')]...
                         ,strcat(line,cell2mat(strcat(settings.lineformat, seperators)))...
                        ),tabledata(i,:))...
                );
        end
    end
    seperators{w} = [tab m('\\') nl];
    if hh == h
        line = [m(tableheadline{end}) tab '&'];
    else
        line = '';
    end
    t = strcat(t,...
            sprintf(...
             sprintf( [nl m('%s')]...
                     ,strcat(line,cell2mat(strcat(settings.lineformat, seperators)))...
                    ),tabledata(end,:))...
            );

    s = ssprintf(settings.tableformat, caption, label, columns, s, t);

end

function [ s ] = ssprintf( s, varargin )
    for i = 1:numel(varargin)
        if ~ischar(cell2mat(varargin(i)))
            error(['invalid string for replacement: ' i ': ' cell2mat(varargin(i))]);
        end
        s = strrep(s, ['%' num2str(i) '$s'], cell2mat(varargin(i)));
    end
end