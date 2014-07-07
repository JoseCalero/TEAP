function Signal = Signal_filter1_low_pass(Signal, cutOffFreq)
%A simple low-pass filter applyed to 1D signals (such as GSR, ECG, etc…).
% Inputs:
%  Signal: the signal to filter (will use the .raw component)
%  cutOffFreq: the cutOff frequency of the filter
% Outputs:
%  Signal: the low-passed-signal

if(nargin ~= 2 || nargout ~= 1)
	error('Usage: Signal = Signal_filter1_low_pass(Signal, cutOffFreq)');
end

Signal_assert_mine(Signal);


%Take the sampling frequency of the signal
Fs = Signal_get_samprate(Signal);

%The normalized cutOff freq
Wn = (2/Fs)*cutOffFreq;

%Make the filter
b = fir1(20, Wn, 'low', kaiser(21, 3));

rawSignal = Signal_get_raw(Signal);

newRaw = filter(b, 1, rawSignal);

Signal = Signal_set_raw(Signal, newRaw);

%Indicate that the signal has been filtered
Signal = Signal_set_preproc_lowpass(Signal);
