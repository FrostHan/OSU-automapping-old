function tp=NNmapping(net,songfile,BPM,offset,BeatDivisor)

Naji=41;
ajiduration=0.04; %in second
aji=zeros(1e7,Naji);

%-----------pre process---------------
[data,fs]=audioread(songfile);

L=size(data,1);

timedistance=(60/(BPM*BeatDivisor))*1000;
%n·ÖÅÄµÄ¼ä¸ô(in ms)

N=floor((BPM*BeatDivisor)*(1000*(L/fs)-offset)/60000);
%N:numbers of time points (structure)-- 'tp'

tp=struct('time',zeros(N,1),'object',zeros(N,1),'position',zeros(N,2));
%-----------------------------------------------------------------
% ##time: in ms, for convenience of osu!
%
% ##object:(n)  
%       n->1:note;  n->2:sliderhead;  n->3:slidertail; n->0:no object
%
% ##position: (x,y) 
%       position=

%generate tp.time
tp.time=linspace(offset,offset+(N-1)*timedistance,N);


%generate tp.object using NN
[songdata,fs]=audioread(songfile);
Nfft=fs*ajiduration;
[S,~,T]=spectrogram(songdata(:,1),Nfft,Nfft/2,Nfft,fs);
S2=abs(S.^2)/max(max((abs(S.^2))));


for v=1:length(tp.time)
    [~,Tind]=min(abs(1000*T-tp.time(v)));
    if Tind-floor(Naji/2)>0&&Tind+floor(Naji/2+0.5-1)<length(T)
        data=S2(:,Tind-floor(Naji/2):Tind+floor(Naji/2+0.5-1));
        aji=sum(data,1);
        Y=net(aji');
        [~,objectind]=max(Y);
        tp.object(v)=objectind-1;
    end
    
end



end