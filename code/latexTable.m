function [ s ] = latexTable(tablehead, tabledata, caption)
%latexTable A function to transform a matrix + tableheading into a beautiful latex table

    [~, w] = size(tablehead);
    if w ~= 1 
    settings = struct('firstline', sprintf('%s\n','\toprule'),...
                      'headline',  sprintf('%s\n','\midrule'),...
                      'lastline',  sprintf('%s\n','\bottomrule'),...
                      'linesep', '',...
                      'columnsep', '',...
                      'leftsep','',...
                      'leftheadsep','|',...
                      'rightsep',''...
                      );
    else
    settings = struct('firstline', sprintf('%s\n','\toprule'),...
                      'headline',  '',...
                      'lastline',  sprintf('%s\n','\bottomrule'),...
                      'linesep', '',...
                      'columnsep', '',...
                      'leftsep','',...
                      'leftheadsep','|',...
                      'rightsep',''...
                      );
    end
    [~, w] = size(tabledata);
    lineformat = cellstr(char(ones(w,1)*'%3.3f'))';
    s = latexTableInt(tablehead, tabledata, caption, lineformat, settings);
end

function [ s ] = latexTableInt(tablehead, tabledata, caption, lineformat, settings)
% main code for generation of the table
[hh, wh] = size(tablehead);
[hf, wf] = size(lineformat);
[h, w] = size(tabledata);

if hf ~=1
    error('no format given!');
end
if h < 1
    error('no tabledata!');
end
if wf ~= w 
    error('number of columns of format and data does not match!');
end

seperators = cellstr(char(ones(w,1)*'\t& '))';
seperators{w} = strcat('\t',mask(strcat('\\',settings.headline,'\endfirsthead')),'\n');

columns = cellstr(char(ones(w,1)*strcat('S',settings.columnsep)))';

if w==wh && hh==1
    columns = sprintf('%s%s%s',settings.leftsep,cell2mat(columns),settings.rightsep);
    for i = 1:w
        tablehead{i} = sprintf(mask(mask('\multicolumn{1}{p{2cm}}{%s}')),tablehead{i});
    end
    s = strcat('\caption{',caption,'}\\',settings.firstline,sprintf('\n'));
    s = strcat(s,sprintf(sprintf('%s',cell2mat(strcat(tablehead,seperators)))));
    seperators{w} = strcat('\t',mask(strcat('\\',settings.headline,'\endhead')),'\n');
    s = strcat(s,'\caption{',caption,' (continued)}\\',settings.firstline,sprintf('\n'));
    s = strcat(s,sprintf(sprintf('%s',cell2mat(strcat(tablehead,seperators)))));
    
    seperators{w} = sprintf(mask(strcat('\t',mask('\\%s'),'\n')),mask(settings.linesep));

    if h > 1
        t = sprintf(sprintf('%s',cell2mat(strcat(lineformat,seperators))),tabledata(1:end-1,:)');
        seperators{w} = '\n';
    else
        t='';
    end

    te = sprintf(sprintf(mask(mask('%s\\')),cell2mat(strcat(lineformat,seperators))),tabledata(end,:));
elseif h==hh && wh==1
    s = sprintf(strcat(  mask('\caption{'),mask(caption),mask('}'),mask('\\'),'\n',mask(settings.firstline),mask('\endfirsthead'),'\n',mask('\caption{'),mask(caption),mask(' (continued)}'),mask('\\'),'\n',mask(settings.firstline),mask('\endhead'),'\n'));
    columns = sprintf('%sl%s%s%s',settings.leftsep,settings.leftheadsep,cell2mat(columns),settings.rightsep);

    seperators{w} = sprintf(mask(strcat('\t',mask('\\%s'),'\n')),mask(settings.linesep));

    t='';
    te='';
    for i=1:h
        t = strcat(t,...
            sprintf(sprintf(strcat('\n',mask(mask('%s'))),strcat(mask(tablehead{i}),'&',cell2mat(strcat(lineformat,seperators)))),tabledata(i,:))...
            );
    end
    
else
    error('invalid heading');
end

s = sprintf(strcat(mask('\begin{longtable}{%s}'),'\n',...
                   mask('%s%s%s%s%s'),'\n'),...
                   columns,...
                   s,...
                   t,...
                   te,...
                   settings.lastline,...
                   '\end{longtable}');

end

function [s] = mask(s)
% helper function for masking escape characters inside a sprintf
    s = strrep(s,'\','\\');
end