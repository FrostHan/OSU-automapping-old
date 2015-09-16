function [B,isnote]=rhythmload(songfile,osufile)

osufp=fopen(osufile);

%---------get offset& bpm----------------
tline=fgetl(osufp);
while ~feof(osufp)&&~strcmp(tline,'[TimingPoints]')
    tline=fgetl(osufp);
end
A=fscanf(osufp,'%d,%lf,');
bpm=6e4/A(2);
offset=A(1);

%--------------get objects-----------------
while ~feof(osufp)&&~strcmp(tline,'[HitObjects]')
    tline=fgetl(osufp);
end
B=zeros(1e4,5);
i=0;

%automapping1(songfile,bpm,offset,osufile,0);
hold on

while ~feof(osufp)
    i=i+1;
    B(i,:)=fscanf(osufp,'%d,%d,%d,%d,%d');
    s=fscanf(osufp,'%s',1);
    fgetl(osufp);
    if length(s)==9
        isnote(i)=1;
        plot(B(i,3),0,'marker','.','markersize',30,'color','yellow')
    else 
        isnote(i)=0;
        plot(B(i,3),0,'marker','.','markersize',30,'color','red')
    end
end
close gcf
fclose(osufp);

%-------------spectrogram----------------
if ~nargout
    figure
    hold on
    [songdata,fs]=audioread(songfile);
    spectrogram(songdata(:,1),500,500/2,500,fs);

    for i=1:length(isnote)
        if isnote(i)
            plot(0,B(i,3)/1000,'marker','.','markersize',30,'color','yellow')
        else 
            plot(0,B(i,3)/1000,'marker','.','markersize',30,'color','red')
        end
    end
end
B(length(isnote)+1:end,:)=[];

%note:           yellow
%slider head:    red
%slider back:    purple
%slider end:     blue
%spinner start:  black
%spinner end:    gray
end