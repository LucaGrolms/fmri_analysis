function IC = SOCK_classify

% This function classifies the ICs into three categories of definite artifact, possible artifact and unlikely artifact.  
% 
% Output:
% IC = The final IC structre containg the IC classification (in IC.cat) as decided by SOCK. 
% _______________________________________________________________________
% Copyright (C) 2012-2013 The Florey Institute of 
%    Neuroscience and Mental Health, Melbourne, Australia
%
% Coded by Kaushik Bhaganagarapu
%
% This file is part of the SOCK software package. 
% Please see sock.m for more information.

% SOCK is free software: you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, 
% or (at your option) any later version.
% 
% SOCK is distributed in the hope that it will be useful, 
% but WITHOUT ANY WARRANTY; without even the implied warranty 
% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program (see LICENCE.txt). If not, 
% see <http://www.gnu.org/licenses/>.
%
% _______________________________________________________________________


% Set the thresholds for the edge and CSF activity. 
EA_threshold = 1.5; % values greater than 1.5 will be rejected
CSF_threshold = 30; % values greater than 30 will be rejected

temporal_filtering = 0; % Set this to 0 if temporal filtering has already been done of the data. Otherwise, it will incorrectly use the temporal criteria.  
load IC
load std_edge_activity

smooth_ICs = IC.smooth_ICs;
subsmooth_ICs = IC.subsmooth_ICs;
unsmooth_ICs = IC.unsmooth_ICs;

% TEST ONLY - Not used in final output
% Set the std_edge_activity threshold. ICs with edge activity greater then 1.1 are labelled with a flag. They will not be rejected but users will be warned that they contain high edge activity.
edge_thres = 1.1;

IC.observe = zeros(1,length(IC.smooth));
IC.edge_flag = zeros(1,length(IC.smooth));
IC.CSF_flag = zeros(1,length(IC.smooth));

for i=1:length(IC.smooth)

	% If IC is smooth, than accept it for now regardless of whether it has significant CSF or edge activation.
	if(find(IC.smooth_ICs(:)==i)) 
		IC.cat(i) = 1;
	end

	% If IC is not smooth (or subsmooth), than put it in the doubtful category, regardless of whether it has significant CSF or edge activation.
	if( find(IC.subsmooth_ICs(:)==i) ) 
		IC.cat(i) = 2;
	end
	
	if( find(IC.unsmooth_ICs(:)==i) )
		IC.cat(i) = 2;
	end

	if(find(IC.smooth_ICs(:)==i)) % If smooth
		if(strcmp(IC.edge_activity_label_spatial(i), 'low'))
			if(IC.CSF_activity(i)<=10)
				IC.cat(i) = 1;	
			elseif(IC.CSF_activity(i)>10)
				IC.cat(i) = 2;
			end
		elseif(strcmp(IC.edge_activity_label_spatial(i), 'high'))
			if(IC.CSF_activity(i)<=10)
				IC.cat(i) = 2;	
			elseif(IC.CSF_activity(i)>10)
				IC.cat(i) = 3;
			end
		end
	elseif(find(IC.subsmooth_ICs(:)==i)) % If subsmooth
		if(strcmp(IC.edge_activity_label_spatial(i), 'low'))
			if(IC.CSF_activity(i)<=10)
				if(find(IC.high_freq_non_noise_ICs==i))
					IC.cat(i) = 2;
				elseif(find(IC.high_freq_noise_ICs==i))
					if(temporal_filtering == 1)
						IC.cat(i) = 3;
					else
						IC.cat(i) = 2;
					end
				end
			elseif(IC.CSF_activity(i)>10)
				if(find(IC.high_freq_non_noise_ICs==i))
					IC.cat(i) = 3;
				elseif(find(IC.high_freq_noise_ICs==i))
					IC.cat(i) = 3;
				end
			end
		elseif(strcmp(IC.edge_activity_label_spatial(i), 'high'))
			if(IC.CSF_activity(i)<=10)
				if(find(IC.high_freq_non_noise_ICs==i))
					IC.cat(i) = 2;
				elseif(find(IC.high_freq_noise_ICs==i))
					IC.cat(i) = 3;
				end
			elseif(IC.CSF_activity(i)>10)
				if(find(IC.high_freq_non_noise_ICs==i))
					IC.cat(i) = 3;
				elseif(find(IC.high_freq_noise_ICs==i))
					IC.cat(i) = 3;
				end
			end	
		end

	elseif(find(IC.unsmooth_ICs(:)==i)) % If unsmooth
		if(strcmp(IC.edge_activity_label_spatial(i), 'low'))
			if(IC.CSF_activity(i)<=10)
				IC.cat(i) = 3;	
			elseif(IC.CSF_activity(i)>10)
				IC.cat(i) = 3;
			end
		elseif(strcmp(IC.edge_activity_label_spatial(i), 'high'))
			IC.cat(i) = 3;	
		end
	end

	
	% If an IC has edge activity over 1.5 or CSF activity over 30 reject them regardless of their smoothness. 
	if(strcmp(IC.edge_activity_label_spatial(i), 'high') | IC.CSF_activity(i) > 10)
		
		if(strcmp(IC.edge_activity_label_spatial(i), 'high'))
			if(std_edge_activity(i) > EA_threshold)
				IC.cat(i) = 3;
			else
				IC.edge_flag(i) = 1;
			end
		end

		if(IC.CSF_activity(i) > 10)
			if(IC.CSF_activity(i) > CSF_threshold)
				IC.cat(i) = 3;
			else
				IC.CSF_flag(i) = 1;
			end
		end
	end

end % END looping through ICs

save IC

IC.artifacts = find(IC.cat==3);
IC.non_artifacts = find(IC.cat==1 | IC.cat==2);

end % function
