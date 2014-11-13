function [  ] = example(  )
% Demo code to show how easy it is to create tables with latextable

    p=path();
    path(path, '../code/');

    sa('testtable1.tex',latexTable({'abc', 'def'}, randi(4,2),'The first table'));

    sa('testtable2.tex',latexTable({'abc'; 'def'}, rand(2,4),'The second table'));
    
    path(p);
    
end

function [ ] = sa( file, string )
% helper function for writing files "functional" style
    fid = fopen(file,'w+');
    fwrite(fid, string);
    fclose(fid);
end