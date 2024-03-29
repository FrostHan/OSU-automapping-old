function [net,aji,ren]=getosudatas(mapidrange,osudir)

% mapidrange=[id_start,id_end]
% osudir is the directory of osu song file. such as
% osudir='E:\Program Files (x86)\osu!\Songs\'

if nargin<2
    osudir='E:\Program Files (x86)\osu!\Songs\';
end

%initailize
Naji=41;
ajiduration=0.04; %in second
aji=zeros(1e7,Naji);
isnote=zeros(1e7,1);
issliderhead=zeros(1e7,1);
isslidertail=zeros(1e7,1);
isnone=zeros(1e7,1);

dirs=dir(osudir);
Nd=length(dirs);

j=0;
songdir=cell(10000,1);
mapid=zeros(10000,1);
for k=1:Nd
    mapname=dirs(k).name;
    if length(mapname)>6
        mapidtmp=str2double(mapname(1:6));
        
        if length(mapidtmp)>1
            mapidtmp=[];
        end
    else
        mapidtmp=[];
    end
    if (~isempty(mapidtmp))&&(mapidrange(1)<=mapidtmp)&&(mapidrange(2)>=mapidtmp)
        j=j+1;
        mapid(j)=mapidtmp;
        songdir{j}=strcat(osudir,mapname,'\');
    end
end
songdir(j+1:end)=[];
%mapid(j+1:end)=[];

mtmp=1;

for N=1:j %the N'th song
    %---------find the main diff--------------
    diffs=dir(songdir{N});
    y=0;
    x=0;
    w=1;
    diffbytes=zeros(1e4,1);
    numtmp=zeros(1e4,1);
    for z=1:length(diffs)
       diffname=diffs(z).name;
       
       if (~isempty(strfind(diffname,'Oni')))||(~isempty(strfind(diffname,'oni')))||(~isempty(strfind(diffname,'NM')))...
               ||(~isempty(strfind(diffname,'MX')))||(~isempty(strfind(diffname,'4K')))||(~isempty(strfind(diffname,'5K')))...
               ||(~isempty(strfind(diffname,'6K')))||(~isempty(strfind(diffname,'7K')))||(~isempty(strfind(diffname,'8K')))
           w=0;%w=0 means taiko diff or mania diff
       end
       
       if length(diffname)>3&&strcmp(diffname(end-2:end),'osu')
           y=y+1;
           diffbytes(y)=diffs(z).bytes;
           numtmp(y)=z;
       end
       if length(diffname)>3&&strcmp(diffname(end-2:end),'mp3')
           songfile=[songdir{N},diffs(z).name];
           x=1;%x=1 means there is a mp3 file
       end
    end
    if y  %y>0 means there is a osufile
       [~,maxind]=max(diffbytes);
       num=numtmp(maxind);
       osufile=[songdir{N},diffs(num).name];
    end
%-------------------------------------------------------------
%-------------------- get data--------------------------------
%-------------------------------------------------------------
    if y&&x&&w
        
        osufp=fopen(osufile);
        %---------get offset& bpm----------------
        tline=fgetl(osufp);
        while ~feof(osufp)&&~(length(tline)>12&&strcmp(tline(1:12),'BeatDivisor:'))
            tline=fgetl(osufp);
        end
        BeatDivisor=str2double(tline(13:end));%beat divisor
        
        while ~feof(osufp)&&~strcmp(tline,'[TimingPoints]')
            tline=fgetl(osufp);
        end
        
        %show the song that is processing
        osufile
        
        A=fscanf(osufp,'%d,%lf,');
        BPM=6e4/A(2);
        offset=A(1);
        timedistance=(60/(BPM*BeatDivisor))*1000;
        %-----------end get offset&bpm-----------
        

        
        tp=loadtiming(songfile,BPM,offset,BeatDivisor);
        ntp=length(tp.time);
        
        %------------get tp.objec-------------------------------------
        while ~feof(osufp)&&~strcmp(tline,'[HitObjects]')
            tline=fgetl(osufp);
        end
        
        while ~feof(osufp)
            %tp.object: 0->empty; 1->note; 2->sliderhead; 3->slidertail;
            % consider spinner as a slider, reverse slider as notes
             tline=fgetl(osufp);
             p=strfind(tline,',');
             time1=str2double(tline(p(2)+1:p(3)-1));%note time or sliderhead time
             if ~isempty(strfind(tline,'|'));
                 RN=str2double(tline(p(6)+1:p(7)-1));%number of reverse
                 if length(p)>=8   
                    sliderlength=str2double(tline(p(7)+1:p(8)-1));%slidertail length
                 else
                    sliderlength=str2double(tline(p(7)+1:end));
                 end
                    sliderspeed=GetSliderSpeed( time1, osufile );
                 time2=sliderspeed*sliderlength*timedistance*BeatDivisor+time1;%slidertail time
             end
             
             if ~isempty(strfind(tline,'|'))&&RN==1 %slider
                [~,tind]=min(abs(tp.time-time1));
                tp.object(tind)=2;
                [~,tind]=min(abs(tp.time-time2));
                tp.object(tind)=3;
             elseif ~isempty(strfind(tline,'|'))&&RN>1  %reverse slider
                 timetmp=linspace(time1,time2,RN+1);
                 for u=1:RN+1
                    [~,tind]=min(abs(tp.time-timetmp(u)));
                    tp.object(tind)=1;
                end
             elseif isempty(strfind(tline,'|'))&&length(p)==5%note
                [~,tind]=min(abs(tp.time-time1));
                tp.object(tind)=1;
             end
        end
        fclose(osufp);
        fclose all;
        %---------------end get tp.object----------------------------
        
        %----------------get the results---------------------
        [songdata,fs]=audioread(songfile);
        Nfft=fs*ajiduration;
        [S,~,T]=spectrogram(songdata(:,1),Nfft,Nfft/2,Nfft,fs);
        S2=abs(S.^2)/max(max((abs(S.^2))));
        for v=1:ntp
            [~,Tind]=min(abs(1000*T-tp.time(v)));
            if Tind-floor(Naji/2)>0&&Tind+floor(Naji/2+0.5-1)<length(T)
                m=mtmp+v-1;
                
                data=S2(:,Tind-floor(Naji/2):Tind+floor(Naji/2+0.5-1));
                aji(m,:)=sum(data,1);
                

                switch tp.object(v)
                    case 0
                        isnone(m)=1;
                    case 1
                        isnote(m)=1;
                    case 2
                        issliderhead(m)=1;
                    case 3
                        isslidertail(m)=1;
                end
            end
            
        end
        mtmp=mtmp+ntp;
        %-------------------------------------------
    end %end of if y&&x
end%end da xun huan


%clear the rest parts of vectors
aji(mtmp:end,:)=[];
isnote(mtmp:end,:)=[];
issliderhead(mtmp:end,:)=[];
isslidertail(mtmp:end,:)=[];
isnone(mtmp:end,:)=[];

ren=[isnone,isnote,issliderhead,isslidertail];
net=fitnet(10);
net.divideParam.trainRatio=60/100;
net.divideParam.valRatio = 20/100;
net.divideParam.testRatio = 20/100;
net=train(net,aji',ren');


end



