function createOsuFile(tp,diffname,title,mp3Name,BPM,offset)

BeatDivisor=4;
SliderMultiplier=0.18;
timedistance=(60/(BPM*BeatDivisor))*1000;
AR=9;
OD=7;
CS=4;
HP=6;

osufp=fopen('a.osu','w');


fprintf(osufp,'%s\r\n\r\n','osu file format v14');
fprintf(osufp,'%s\r\n','[General]');
fprintf(osufp,'%s','AudioFilename: ');
fprintf(osufp,'%s\r\n',mp3Name);
fprintf(osufp,'%s\r\n','AudioLeadIn: 0');
fprintf(osufp,'%s\r\n','PreviewTime: -1');
fprintf(osufp,'%s\r\n','Countdown: 1');
fprintf(osufp,'%s\r\n','SampleSet: Soft');
fprintf(osufp,'%s\r\n','StackLeniency: 0.7');
fprintf(osufp,'%s\r\n','Mode: 0');
fprintf(osufp,'%s\r\n','LetterboxInBreaks: 1');
fprintf(osufp,'%s\r\n\r\n','WidescreenStoryboard: 0');
fprintf(osufp,'%s\r\n','[Editor]');
fprintf(osufp,'%s\r\n','DistanceSpacing: 1');
fprintf(osufp,'%s\r\n','BeatDivisor: 4');
fprintf(osufp,'%s\r\n','GridSize: 4');
fprintf(osufp,'%s\r\n\r\n','TimelineZoom: 1');
fprintf(osufp,'%s\r\n','[Metadata]');
fprintf(osufp,'%s','Title:');
fprintf(osufp,'%s\r\n',title);
fprintf(osufp,'%s','TitleUnicode:');
fprintf(osufp,'%s\r\n',title);
fprintf(osufp,'%s\r\n','Artist:111');
fprintf(osufp,'%s\r\n','ArtistUnicode:111');
fprintf(osufp,'%s\r\n','Creator:frostofwinter');
fprintf(osufp,'%s\r\n',['Version:',num2str(diffname)]);
fprintf(osufp,'%s\r\n','Source:');
fprintf(osufp,'%s\r\n','Tags:');
fprintf(osufp,'%s\r\n','BeatmapID:-1');
fprintf(osufp,'%s\r\n\r\n','BeatmapSetID:-1');
fprintf(osufp,'%s\r\n','[Difficulty]');
fprintf(osufp,'%s\r\n',['HPDrainRate:',num2str(HP)]);
fprintf(osufp,'%s\r\n',['CircleSize:',num2str(CS)]);
fprintf(osufp,'%s\r\n',['OverallDifficulty:',num2str(OD)]);
fprintf(osufp,'%s\r\n',['ApproachRate:',num2str(AR)]);
fprintf(osufp,'%s\r\n',['SliderMultiplier:',num2str(SliderMultiplier)]);
fprintf(osufp,'%s\r\n\r\n','SliderTickRate:1');
fprintf(osufp,'%s\r\n\r\n','[Events]');
fprintf(osufp,'%s\r\n','[TimingPoints]');
TIME=num2str(offset);
BPM=num2str(60000/BPM,15);
TimingPoint=strcat(TIME,',',BPM,',4,2,0,100,1,0');
fprintf(osufp,'%s\r\n\r\n',TimingPoint);
fprintf(osufp,'%s\r\n','[HitObjects]');

for k=1:length(tp.object)
    
if tp.object(k)==1

            fprintf(osufp,['%d,%d,',int2str(tp.time(k)),',1,0,0:0:0:0:\r\n'],round(400*rand(1,1)),round(300*rand(1,1)));

end

if tp.object(k)==2
            m=0;
            while m==0||tp.object(k+m)==0
                m=m+1;
                if  k+m-1==length(tp.object)%end of song
                    fprintf(osufp,['%d,%d,',int2str(tp.time(k)),',1,0,0:0:0:0:\r\n'],round(400*rand(1,1)),round(300*rand(1,1)));
                elseif tp.object(k+m)==3 %a slidertail matches sliderhead
                    sliderlength=round((tp.time(k+m)-tp.time(k))/(BeatDivisor*timedistance)*100*SliderMultiplier);
                    a=round(rand()*400);
                    b=round(rand()*300);
                    tp.object(k+m)=4;
                    fprintf(osufp,['%d,%d,',int2str(tp.time(k)),',2,0,L|%d:%d,1,%f\r\n'],a,b,a+sliderlength,b,sliderlength);
                elseif  tp.object(k+m)==2||tp.object(k+m)==1 %sliderhead doesn't match a slidertail
                    sliderlength=round((tp.time(k+m-1)-tp.time(k))/(BeatDivisor*timedistance)*100*SliderMultiplier);
                    a=round(rand()*400);
                    b=round(rand()*300);
                    fprintf(osufp,['%d,%d,',int2str(tp.time(k)),',2,0,L|%d:%d,1,%f\r\n'],a,b,a+sliderlength,b,sliderlength);
                end
            end
end

if tp.object(k)==3
            fprintf(osufp,['%d,%d,',int2str(tp.time(k)),',1,0,0:0:0:0:\r\n'],round(400*rand(1,1)),round(300*rand(1,1)));
end


end




fclose(osufp);

end