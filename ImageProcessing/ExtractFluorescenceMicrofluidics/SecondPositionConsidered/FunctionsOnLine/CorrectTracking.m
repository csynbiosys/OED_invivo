%%
function [] = CorrectTracking(pDIC, ident2)


% Get names of current images 
filePatternT = fullfile([pDIC, '\Tracking\'], 'trk-img_*.tif');
FilesT = dir(filePatternT);
% Get number of frames for channel
maxidT=length(FilesT);

%%
% Correct for wrong divisions (sometimes Lineage Mapper divides cells by
% the end of the experiment into different cells even when these have the
% same identifier, so the error does not come from segmentation). 

trki = cell(1,maxidT); % Empty cell array that will contain all the tracking masks
trdi = []; % Vector that will contain the identifiers of the true cells after being corrected for false divisions (to use latter to avoid errors wen extracting division indexes) 
aldi = []; % Vector that will contain all the identifiers for cells before false cell correction

f = waitbar(0,'Correcting False Cell Divisions...'); % Open a dialog box with a progress bar for the following task

for i=1:maxidT % Iterate over all masks
    
    waitbar(i/maxidT) % Define what the progress bar will be showing during the progress
    
    num = num2str(i,'%.3u');
    orM = imread([pDIC, '\Segmentation\Components\img_',num,'.tif']); % Original segmentation mask
    trM = imread([pDIC, '\Tracking\trk-img_',num,'.tif']); % Tracking mask result
    
    cidM = unique(orM); % Get the id numbers for all cells in the original mask
    cidM = cidM(2:end); % Remove the background id value (0)
    
    cidT = unique(trM); % Get the id numbers for all cells in the tracking mask
    cidT = cidT(2:end); % Remove the background id value (0)
    aldi = [aldi, double(cidT')];
    for j=1:length(double(cidM')) % Loop to go over each original mask identified cell
        tmpc = (orM==double(cidM(j))); % Original mask with only one cell in it at each iteration
        tin = find(tmpc); % Get matrix indexes for non 0 elements
        
        ptc = trM(tin); % Pixels to potentially correct, to see if they all have the same number
        
        if length(unique(ptc))~=1 % In the case where the cell have different identifiers in it (tracking issue)
            trM(tin)=uint16(ones(length(ptc),1))*min(ptc); % Take the smallest identifier as the one for the whole cell (the original identifier)
        end
    end
    
    trki{i} = trM; % Save the corrected tracking mask into a cell array that will contain all the tracking masks
    ts = unique(double(trM))';
    trdi = [trdi, ts(2:end)];
end

delete(f) % Close progress bar

trdi = unique(trdi); % Remove repeated elements
aldi = unique(aldi); 
deel = setdiff(aldi,trdi); % Completely deleted cell indexes
save([pDIC, '\Tracking\',ident2,'_TrakedMasksCorrected.mat'], 'trki') % Save results in case something crashes latter on 


%%
% Correct for good divisions (Lineage Mapper has an issue, which is that
% when a cell divides the two daughters get a different identifier, so you
% lose track of the original mother cell, the folowing part of the code
% attempts to correct for this).

div = csvread([pDIC,'\Tracking\trk-division.csv'],1,1); % CSV file with the track of cell divisions. It only extracts a matrix with Mother cell in first column, and the two daughter cells in the second and third column.
pos = csvread([pDIC,'\Tracking\trk-positions.csv'],1,0); % CSV file with the position of cells at each frame. Columns are Cell ID, Frame number, X Coordinate and Y Coordinate. 

f = waitbar(0,'Extracting mother cell identifiers...'); % Open a dialog box with a progress bar for the following task

% Extract indexces of the mother cells
ident = div(:,1); % Identifier of the mother cells (not corrected)
ti = cell(max(max(div)),1); % Empty cell array for each one of the cells in the tracking mask (acounts for the fact that no divisions have been detected)
for i=1:max(max(div)) % Loop over all cell identifiers detected to check if there is any division asociated to the number
    waitbar(i/max(max(div))) % Define what the progress bar will be showing during the progress
    if isempty(unique(i==deel)) % Accounts for the case where a cell index has been completely removed in the previous section
    
        temp = ident==i; % Check if the current cell identifier is present in the mother divisions list
        ti{i} = NaN(1,max(max(div))); % Empty nan vector for each cell of ti where the length is the maximum number of cells to account for the case that there i only one cell that divides
        if length(unique(temp))==1 && length(temp)>1 % Case of no division (current identifier is not present in the mother cell list)
            % if the cell index is in ident and ident is not of length 1
            ti{i}(1)=i; % Add identifier to the empty vector and that is it. 
        elseif ~isempty(find(ident==i)) && ~isempty(find(div(:,1)==i)) % Case where the cell that is being checked has actually divided at some point
            % If the cell index is indeed inside ident and inside div (accounts
            % for when we set an index to 0 to not be repeated)

            indel = find(ident==i); % Find index of mother division of the current cell in the list ident
            ti{i}(1)=i; % Add the identifier into the current position of ti (the original)

            i1=[];i2=[];i3=[];

            for h=1:length(pos) % Loop over the total number of positions (hence, total number of cells in all frames without considering relation between them)
                if pos(h,1)==div(indel,1) % Check if the cell ID from the position file is the one that is being currently annalysed
                    i1 = [i1;pos(h,:)]; % If that is the case, take the entire row of the position file
                elseif  pos(h,1)==div(indel,2) % Check if the cell ID from the position is the one for the first daughter
                    i2 = [i2;pos(h,:)]; % If that is the case, take the entire row of the position file
                elseif  pos(h,1)==div(indel,3) % Check if the cell ID from the position is the one for the second daughter
                    i3 = [i3;pos(h,:)]; % If that is the case, take the entire row of the position file    
                end
            end

            sub1x = round(abs(i1(end,3)-i2(1,3)),2); % Absolute difference in x position between the mother cell in the last frame and the first daughter in her first frame
            sub1y = round(abs(i1(end,4)-i2(1,4)),2); % Absolute difference in y position between the mother cell in the last frame and the first daughter in her first frame
            sub2x = round(abs(i1(end,3)-i3(1,3)),2); % Absolute difference in x position between the mother cell in the last frame and the second daughter in her first frame
            sub2y = round(abs(i1(end,4)-i3(1,4)),2); % Absolute difference in y position between the mother cell in the last frame and the second daughter in her first frame

            if sub1x+sub1y < sub2x+sub2y % If the sume of x and y distances of the first daughter is smaller (more likely to be the mother cell)
                ti{i}(2)=div(indel,2); % Adds the identifier of the first division to the vector ti for the current dividing cell
                indel2 = find(ident==div(indel,2)); % Check if this daughter (original mother) has divided latter on, and if so keep the index in ident for it
            elseif sub1x+sub1y > sub2x+sub2y % If the sume of x and y distances of the second daughter is smaller (more likely to be the mother cell)
                ti{i}(2)=div(indel,3); % Adds the identifier of the first division to the vector ti for the current dividing cell
                indel2 = find(ident==div(indel,3)); % Check if this daughter (original mother) has divided latter on, and if so keep the index in ident for it
            end
            div(indel,1)=0; % Turn the index in div for the current cell to 0
            tp = div(indel2,1); % Turn the next division of the dauter to 0 in div (if there is any) keep track of its index
            div(indel2,1)=0; % If the previous line does something, set the identifier to 0

            c=3; % index to start from the 3rd division if there is any
            for j=1:length(ident) % Loop over the number of divisions
                if ~isempty(indel2) % Check if there is any more divisions for the cell checking the index stored in tp (it can be empty)
                    i12=[];i22=[];i32=[]; % Same as before to account for the daughters cell position
                    for h=1:length(pos)
                        if pos(h,1)==tp
                            i12 = [i12;pos(h,:)];
                        elseif  pos(h,1)==div(indel2,2)
                            i22 = [i22;pos(h,:)];
                        elseif  pos(h,1)==div(indel2,3)
                            i32 = [i32;pos(h,:)];    
                        end
                    end

                    sub1x2 = round(abs(i12(end,3)-i22(1,3)),2);
                    sub1y2 = round(abs(i12(end,4)-i22(1,4)),2);
                    sub2x2 = round(abs(i12(end,3)-i32(1,3)),2);
                    sub2y2 = round(abs(i12(end,4)-i32(1,4)),2);

                    if sub1x2+sub1y2 < sub2x2+sub2y2 % Same as before to put in the empty vector ti the identifiers for the mother cell
                        ti{i}(c)=div(indel2,2);
                        indel2 = find(ident==div(indel2,2));
                    elseif sub1x2+sub1y2 > sub2x2+sub2y2
                        ti{i}(c)=div(indel2,3);
                        indel2 = find(ident==div(indel2,3));
                    end

                    div(indel2,1)=0; % Set the cell identifier to 0 in div if there is any more divisions (this linses setting what has already been check to 0 is to keep iterating over the same table without repeating the process and end up with different cells with the same set of identifiers minus the initial ones)
                    c=c+1; % Increase the division count by oneand reiterate if required
                end
            end
        end
    end
end
delete(f) % Close progress bar
save([pDIC,'\Tracking\',ident2,'-testAll.mat'], 'ti') % Save indexes

%%
% Remove repeated indexces
for i=1:length(ti) % Iterate to each cell indez
    temp = ti{i}; % Temporary cell aray index
    temp = temp(~isnan(temp)); % Take non Nan elements
    if ~isempty(temp) % If the vector is not empty
        temp(1)=[]; % Delete the first element
    end
    if ~isempty(temp) % If the vector is not empty after deleting the first element
        for j=1:length(temp) % Iterate over each cell index
            ti{temp(j)}=[]; % Find the index of the daughter cell that is actually the recorded mother and delete the entry so it does not repeat
        end
    end
end

% Make a second structure where the empty entries are not considered
% (deleted)
ti2 = {};
id=1;
for i=1:length(ti)
    if ~isempty(ti{i})
        ti2{id}=ti{i};
        id=id+1;
    end
end


%% 
% Get frame of division
tidiv = cell(1,length(ti2)); % Empty cell that will contain the results
for i=1:length(ti2) % Iterate over the number of cells (not divisions)
    temp = ti2{i}; % Get mother cell IDs
    temp = temp(~isnan(temp)); % Delete Nans from the vector
    tidiv{i}=zeros(2,length(temp)); % Make a 2D vector with the same length as the division events for the cell
    for j=1:length(temp) % Iterate over the number of cell divisions
        tidiv{i}(1,j)=temp(j); % Add the cell identifiers in the first row of the vector
        for h=1:length(pos) % Iterate over the total count of positions (number of cells without connection)
            if pos(h,1)==temp(j) % Search for the first time the cell was identified in a frame
                tidiv{i}(2,j)=pos(h,2); % When statement happens record the frame at which the cell appeared and stop the loop for that cell
                break
            end
        end
    end
end

save([pDIC, '\Tracking\',ident2,'-TrackPosTimeAll.mat'], 'tidiv') % Save the results

%%
% Modify the actual tracking masks with the information aquired

f2 = waitbar(0,'Updating Tracking Masks...'); % Open a dialog box with a progress bar for the following task
noc = length(ti2); % Number of cells
for f=1:maxidT % Iteare over each frame
    waitbar(f/maxidT) % Define what the progress bar will be showing during the progress
    coce = unique(trki{f})'; % Cell indexes contained in the mask
    coce = coce(2:end);
    for c=1:length(ti2) % Itearate over each cell index
        temp = ti2{c}; % Temporary cell aray index
        temp = temp(~isnan(temp)); % Take non Nan elements
        for d=temp % Iterate oer each mother ID content in temp
            if ~isempty(find(trki{f}==d)) % If the ID is present in the current frame f
                w = find(trki{f}==d); % Get the indexes in the image for the cell
                trki{f}(w)=ti2{c}(1); % if so, change the mother ID in the frame to the first ID that is assigned to her
            end
            if ~isempty(find(trki{f}==d)) && (length(find(trki{f}==d)) < 5) % If the ID is present in the current frame f and the "cell" is smaller than 5 pixels (segmentation error?)
                w = find(trki{f}==d); % Get the indexes in the image for the cell
                trki{f}(w)=0; % if so, change the mother ID to 0
                noc=noc-1; % Substract 1 to the total number of cells since this one will not be taken into account
            end
        end
    end
end
delete(f2) % Close progress bar
save([pDIC, '\Tracking\',ident2,'_TrakedMasksCorrected.mat'], 'trki') % Save results

disp(['The total number of cells after correcting for tracking is ', num2str(noc)]); % Let the user know how many cells there are in the experiment



end





