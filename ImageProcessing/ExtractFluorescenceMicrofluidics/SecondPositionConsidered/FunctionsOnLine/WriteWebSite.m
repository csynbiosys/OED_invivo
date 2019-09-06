


function [] = WriteWebSite(datenow, ident)

fil = fopen(['C:\Users\s1778490\Dropbox\OEDinVivoMicrofluidicExperiments\',datenow,'_Microfluidics\',ident,'-Web.html'], 'w');

fprintf(fil, '<!DOCTYPE html>');
fprintf(fil, '\n');
fprintf(fil, '<html>');
fprintf(fil, '\n');
fprintf(fil, '  <head>');
fprintf(fil, '\n');
fprintf(fil, '    <title>My webpage!</title>');
fprintf(fil, '\n');
fprintf(fil, '  </head>');
fprintf(fil, '\n');
fprintf(fil, '  <body>');
fprintf(fil, '\n');
fprintf(fil, '    <h1>Microfluidics Experiments Inducible Promoter</h1>');
fprintf(fil, '\n');
fprintf(fil, '    <div class="image-section">');
fprintf(fil, '\n');
fprintf(fil, '      <div class="section-style">');
fprintf(fil, '\n');
fprintf(fil, '        <p>Citrine Fluorescence plot</p>');
fprintf(fil, '\n');
dir1 = ['.\',ident,'-Citrine.png'];
dir1 = strrep(dir1,'\','/');
fprintf(fil, ['        <img src="',dir1,'" alt="" />']);
fprintf(fil, '\n');
fprintf(fil, '      </div>');
fprintf(fil, '\n');
fprintf(fil, '    <div class="image-section">');
fprintf(fil, '\n');
fprintf(fil, '      <div class="section-style">');
fprintf(fil, '\n');
fprintf(fil, '        <p>Sulforodamine Fluorescence plot</p>');
fprintf(fil, '\n');
dir2 = ['.\',ident,'-Sulforodamine.png'];
dir2 = strrep(dir2,'\','/');
fprintf(fil, ['        <img src="',dir2,'" alt="" />']);
fprintf(fil, '\n');
fprintf(fil, '      </div>');
fprintf(fil, '\n');
fprintf(fil, '    <div class="image-section">');
fprintf(fil, '\n');
fprintf(fil, '      <div class="section-style">');
fprintf(fil, '\n');
fprintf(fil, '        <p>Last time-point captured</p>');
fprintf(fil, '\n');
dir3 = ['.\',ident,'-LastTP1.png'];
dir3 = strrep(dir3,'\','/');
fprintf(fil, ['        <img src="',dir3,'" alt="" />']);
fprintf(fil, '\n');
fprintf(fil, '      </div>');
fprintf(fil, '\n');
fprintf(fil, '\n');
fprintf(fil, '    <div class="image-section">');
fprintf(fil, '\n');
fprintf(fil, '      <div class="section-style">');
fprintf(fil, '\n');
fprintf(fil, '        <p> </p>');
fprintf(fil, '\n');
dir3 = ['.\',ident,'-LastTP2.png'];
dir3 = strrep(dir3,'\','/');
fprintf(fil, ['        <img src="',dir3,'" alt="" />']);
fprintf(fil, '\n');
fprintf(fil, '      </div>');
fprintf(fil, '\n');
fprintf(fil, '\n');
fprintf(fil, '    <h4 id=''date''></h4>');
fprintf(fil, '\n');
fprintf(fil, '  </body>');
fprintf(fil, '\n');
fprintf(fil, '</html>');
fprintf(fil, '\n');
fprintf(fil, '\n');
fprintf(fil, '\n');

fclose(fil);


end













