function sai_unix(command)

% This function executes the unix command needed to run fsl functions throughout the SOCK function.
%  Due to the FSL library path, you might obtain the following errors:

% fslmaths: /opt/MatlabR2010bSP1/sys/os/glnxa64/libstdc++.so.6: version `GLIBCXX_3.4.11' not found (required by fslmaths)
% fslmaths: /opt/MatlabR2010bSP1/sys/os/glnxa64/libstdc++.so.6: version `GLIBCXX_3.4.11' not found (required by /usr/lib/fsl/5.0/libnewimage.so)

% If this happens, copy the output of 'echo $LD_LIBRARY_PATH' into the code of line below and comment out the unix(command) line:

%unix(strcat('export LD_LIBRARY_PATH="RESULT_OF_ECHO_OUTPUT;"', {' '},  command))
unix(command);
end
