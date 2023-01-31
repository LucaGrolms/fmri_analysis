%Change the values of the subject condition file in a meanigful manner
%First read the condition file and check the amount of onsets values based on
%the disposed in names 
%Finally build four separt condition files with the specical dependencies in the
%rows and colums between duration,names and onsets
%This will be done for every colume value and his dependencies in onsets.
%Normaly 4 or 8 conditions are desposited

%Clear the current workspace
clear;

%Select and load the original condition file
filename = spm_select(1,'mat','Select subject''s condition file');
if length(filename) == 0,
	disp('No condition file selected; Change condition will now exit');
	diary off
	return
end


disp(sprintf ('Current Contents of: %s', filename));
whos('-file',filename);

%Load condition values to workspace
load (filename);

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
       durations{rows+j}=durations_values{cols-(j-1)};
    end
  

    %Positon run in names will be copied x times
    current_value = names{run};
    for i=1:rows
        names{run+(i-1)}=current_value;
    end

    %Attach the not change names values to the new position
    for j=run:(cols-1)
       names{rows+j}=names_values{cols-(j-1)};
    end

   
    %Positon run in onsets will copied from colum to rows
    value = onsets{1,run};
    for i=1:rows
        onsets{1,run+(i-1)} = value(i);
    end

    %Attach the not change onsets values to the new position
    for j=run:(cols-1)
       onsets{rows+j}=onsets_values{cols-(j-1)};
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