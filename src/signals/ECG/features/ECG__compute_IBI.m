function ECGSignal = ECG__compute_IBI( ECGSignal )
%Computes the IBI if it is not yet available
% Inputs:
%  ECGSignal: the ECG signal
% Outputs:
%  ECGSignal: the ECG signal containing the computed IBI signal
%
%Copyright Guillaume Chanel 2015

%Compute the signal if it has not been already computed
if(isempty(Signal__get_raw(ECGSignal.IBI)))
    
    %Get information on the ECG signal
    rawSignal = Signal__get_raw(ECGSignal);
    samprate = Signal__get_samprate(ECGSignal);

    %Compute IBI
    newfs = 256; %Hz, as needed by rpeakdetect
    ECG = resample(rawSignal, newfs, samprate); %WARN what happens if samprate/newfs is not a integer ?
    if size(ECG,1)<size(ECG,2)
        ECG = ECG';
    end
    [hrv, R_t, R_amp, R_index, S_t, S_amp] = rpeakdetect(ECG, newfs);
    [~, IBI, ~, listePeak] = correctBPM(R_index, newfs);
    
    %If the number of detected peaks is lower than 2 than IBI cannot be
    %computed
    if(length(listePeak) < 2)
        warning(['A least 2 peaks are needed to compute IBI but ' num2str(length(listePeak)) ' were found: result will be NaN'])
        ECGSignal.IBI = Signal__set_raw(ECGSignal.IBI,IBI);
    else
        %Attribute the computed signal to IBI to check if range is correct
        % This is done now because this can cause problems in the resampling
        ECGSignal.IBI = Signal__set_raw(ECGSignal.IBI,IBI);
        Signal__assert_range(ECGSignal.IBI, 0.25, 1.5, 1);
        
        %Resample the signal with the one requested for IBI
        IBI_samprate = Signal__get_samprate(ECGSignal.IBI);
        IBI = interpIBI(listePeak/newfs,IBI_samprate,listePeak(end)/newfs)';
    
        %Attribute the computed signal to IBI
        ECGSignal.IBI = Signal__set_raw(ECGSignal.IBI,IBI);
    end
end

end

