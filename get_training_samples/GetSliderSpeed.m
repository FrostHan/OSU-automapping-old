function [ SliderSpeed  ] = GetSliderSpeed( time, osufile )

% SliderLength = SliderMultiplier* (length/(1 clap))* 100
% length= SliderLength/100/SliderMultipler/(-sliderSpeed/100)

osufp=fopen(osufile);

tline=fgetl(osufp);

while ~feof(osufp)&&~strcmp(tline,'[Difficulty]')
    tline=fgetl(osufp);
end

%Find Slider Multiplier
fgetl(osufp);fgetl(osufp);fgetl(osufp);fgetl(osufp);

%Get Slider Multiplier
Slider=fgetl(osufp);
Slider(1:17)=[];
SliderMultiplier=str2double(Slider);

%Find Timing Points
while ~feof(osufp)&&~strcmp(tline,'[TimingPoints]')
    tline=fgetl(osufp);
end


%Find Exact Place And Get Slider Velocity
A=fscanf(osufp,'%d,%lf,');
B=fscanf(osufp,'%d,%lf,');



if( A(1)>time ) 
    % When Given Variable 'time' is before the first Timing Point
    SliderSpeed=-1;
    return;
end

if(isempty(B))
    %When 'time' is after the last Timing Points
    SliderSpeed=1/100/SliderMultiplier;
    return;
end


while 1
    if(A(1)<=time && B(1)>time )
        if( A(2)>0 )
            SliderSpeed=1/100/SliderMultiplier;return;
        else
            SliderSpeed=1/100/SliderMultiplier/(-A(2)/100);return;
        end
    end
    temp=fscanf(osufp,'%d,%lf,');
    if isempty(temp)
        if( B(1)<=time )
            if( B(2)>0 )
                SliderSpeed=1/100/SliderMultiplier;return;
            else
                SliderSpeed=1/100/SliderMultiplier/(-B(2)/100);return;
            end
        end
    end
    A=B;
    B=temp;
end


end

