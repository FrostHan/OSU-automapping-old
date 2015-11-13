function tp=loadtiming(songfile,BPM,offset,BeatDivisor)
%osu auto mapping by machine learning
%
%offset in ms


%-----------pre process---------------
[data,fs]=audioread(songfile);

L=size(data,1);

timedistance=(60/(BPM*BeatDivisor))*1000;
%n·ÖÅÄµÄ¼ä¸ô(in ms)

N=floor((BPM*BeatDivisor)*(1000*(L/fs)-offset)/60000);
%N:numbers of time points (structure)-- 'tp'


tp=struct('time',zeros(N,1),'object',zeros(N,1),'position',zeros(N,2));
% ##time: in ms, for convenience of osu!
%
% ##object:(n)  
%       n->1:note;  n->2:sliderhead;  n->3:slidertail; n->0:no object
%
% ##position: (x,y) 
%       position=

tp.time=linspace(offset,offset+(N-1)*timedistance,N);

%------------------plot red,white,blue lines-------------
%  [b,a,~]=filter_h(5e3,60,1,fs);
%  data(:,1)=filtfilt(b,a,data(:,1));
%  data(:,1)=data(:,1)/max(data(:,1));

% volumes=zeros(N,1);
% for k=1:N
%     timek=tp.time(k);
%     volumes(k)=mean(abs(data(time2ind(max(offset,timek-timedistance),fs):time2ind(min(tp.time(end),timek+timedistance/2),fs),1)));
%     volumes(k)=max(abs(data(time2ind(max(offset,timek-timedistance/2),fs):time2ind(min(tp.time(end),timek),fs),1)));
% end

timess=data(:,1);
for j=1:length(timess)
    timess(j)=j/fs*1000;
end

% [S,F,T]=spectrogram(data(:,1),1000,1000/2,1000,fs);
% S1=abs(S(:,4500:5500));
% T1=T(4500:5500);
% F1=F;
% contourf(T1*1000,F1,log(S1),'linestyle','none')


%------------------determine objects---------------------





end

% function rhythmJudgeFilter()
% 
% 
% 
% 
% end


function ind=time2ind(t,fs)
%change time( in ms ) to the index of coreesponding data
ind=round(t/1000*fs);

end

