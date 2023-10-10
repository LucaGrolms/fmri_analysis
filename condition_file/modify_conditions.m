function modify_conditions

%Change the values of the subject condition file in a meanigful manner
%First read the condition file and check the amount of onsets values based on
%the disposed in names 
%Finally build four separt condition files with the specical dependencies in the
%rows and colums between duration,names and onsets
%This will be done for every colume value and his dependencies in onsets.
%Normaly 4 or 8 conditions are desposited
%Multi file variant by condition filelist file e.g. "conditionfilelist.txt"

%Clear the current workspace
clear;

%Select and load the file which specify all original condition files
conditionlistfile = spm_select(1,'mat','Select subject''s condition files');
if length(conditionlistfile) == 0,
	disp('No condition file selected; Change condition will now exit');
	diary off
	return
end

%Select and load the file which specify all original condition files
%%%%%% 
f = fopen(conditionlistfile);             
   s = textscan(f,'%s','delimiter','\r\n','CommentStyle', '#'); % Read the whole file into variable s, with each line a separate cell, ignoring comments
 fclose(f);
 s = cellstr(s{1});
 num_rows = size(s,1);

for n=1:num_rows,
   if size(s{n},1) > 0
     conditionLine=textscan(s{n},'%q','CommentStyle', '#'); % Read text of each line into separate fields (supports quoting of delimiter characters)
     conditionLine=conditionLine{1};
   else conditionLine=''; end;
   num_cols=size(conditionLine,1);
    
    filename=conditionLine{1};    
    
    disp(sprintf ('Current Contents of: %s', filename));
    whos('-file',filename);
    
    %Load condition values from file to workspace
    if isfile(filename) ~= 1
         % File does not exist.
         disp(sprintf ('File: %s does not exist!', filename));
    else
       load (filename);
    end
    
    % Caching the values form names and duration
    names_values = names;
    durations_values = durations;
    onsets_values = onsets;
    
    %Check the amount of values in names - normaly 4 or 8 parameter
    cols = size(names,2);
    
    for run=1:cols
    %Changes for rating, UCS, CS+ and CS- 
    
     %Positon run in duration will copied x times
     %Check amount of values in the relevant onset column
     rows = size(onsets{run},1);
    
     %Get the current value to be copied
     current_value = durations{run};
    
      %Start the runs for the relevant parameters
      for i=1:rows
            durations{run+(i-1)}=current_value;
        end
    
        %Attach the not change duration values to the new position
        for j=run:(cols-1)
           durations{rows+j}=durations_values{(j+1)};
        end
      
    
        %Positon run in names will be copied x times
        current_value = names{run};
        for i=1:rows
            names{run+(i-1)}=current_value;
        end
    
        %Attach the not change names values to the new position
        for j=run:(cols-1)
           names{rows+j}=names_values{(j+1)};
        end
    
       
        %Positon run in onsets will copied from colum to rows
        value = onsets{1,run};
        for i=1:rows
            onsets{1,run+(i-1)} = value(i);
        end
    
        %Attach the not change onsets values to the new position
        for j=run:(cols-1)
           onsets{rows+j}=onsets_values{(j+1)};
        end
    
    
       %Build the new condition file name 
       extension = strcat('_',names{1, run});
       new_filename = strrep(filename,'.mat',extension);
       new_filename = strcat(new_filename, '.mat');
       
       %Save the dedicated condition file
       save (new_filename,'durations','names','onsets');
       
       %Display the content of the dedicated condition file name
       disp(sprintf ('New Contents of: %s', new_filename));
       whos('-file',new_filename);
    
       % ReWrite form Caching the values for next run
       names = names_values;
       durations = durations_values;
       onsets = onsets_values;
    end
end

return;