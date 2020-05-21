%%
clear all;
close all;
[y,Fs]=audioread(file path);

y1=y(:,1);
y2=y(:,2);
music=y(:,1)+y(:,2);
autocorrMusic=xcorr(music,music);
autocorrMusic=autocorrMusic((int32(length(autocorrMusic))/2):length(autocorrMusic));
loopThreshold=1500000;
[maxpeak,peakIdx]=max(autocorrMusic(loopThreshold:length(autocorrMusic)));
peakIdx=peakIdx+loopThreshold;
peakIdx/Fs
musicRightShift=music;
for i=1:length(music)-1
    if(i-peakIdx<1)
        musicRightShift(i)=0;
    else
        idx=i-peakIdx;
        musicRightShift(i)=music(idx);
    end
    
end
% musicLeftShift=music;
% for i=1:length(musicLeftShift)-1
%     if(i+peakIdx>length(musicLeftShift))
%         musicLeftShift(i)=0;
%     else
%         idx=i+peakIdx;
%         musicLeftShift(i)=music(idx);
%     end
%     
% end

% leftMusicProduct=music.*musicLeftShift;
rightMusicDifference=musicRightShift-music;
rightMusicProduct=musicRightShift.*music;


%Algorithm 1

window=sign(1:peakIdx);
[windowEnergy]=xcorr(rightMusicProduct,window);
windowEnergy=windowEnergy(int32((length(windowEnergy)/2)):length(windowEnergy));
[~,I2]=max(windowEnergy(1:length(windowEnergy)-peakIdx));
I=(I2);
outputRange=[I:I+peakIdx];
exportAudio(y1,y2,outputRange,"doubleOutputAlgo1.ogg","OutputAlgo1.ogg",Fs)
%

%Algorithm 2

% [windowEnergy,~]=xcorr(leftMusicProduct,window);
% windowEnergy=windowEnergy(int32((length(windowEnergy)/2)):length(windowEnergy));

tarray=1:length(rightMusicDifference);
rightMusicDifference=rightMusicDifference.*(tarray>peakIdx)';
edgeDetectionSize=4.*4096;
[windowEnergy,lag3]=xcorr(abs(rightMusicDifference),((1:edgeDetectionSize).*0+1));
windowEnergy=windowEnergy(int32((length(windowEnergy)/2)):length(windowEnergy));
edgeDetector=sign([-(edgeDetectionSize): (edgeDetectionSize)])';
diffDerivative=xcorr(windowEnergy,edgeDetector);
diffDerivative=diffDerivative(int32((length(diffDerivative)/2)):length(diffDerivative));
[maxi,I3]=max(((abs(diffDerivative(peakIdx:I2+44100*3)))));
I=(I3+int32(edgeDetectionSize*1.75))+peakIdx;
outputRange=[I:I+peakIdx];
exportAudio(y1,y2,outputRange,"doubleOutputAlgo2.ogg","OutputAlgo2.ogg",Fs)
%


function exportAudio(y1,y2,range,fileName1,fileName2,Fs)
loopsong1=[y1(range); y1(range)];
loopsong2=[y2(range); y2(range)];
songg=zeros(length(loopsong1),2);
songg(:,1)=loopsong1';
songg(:,2)=loopsong2';

audiowrite(fileName1,songg,Fs);

loopsong1=[y1(range)];
loopsong2=[y2(range)];
songg=zeros(length(loopsong1),2);
songg(:,1)=loopsong1';
songg(:,2)=loopsong2';

audiowrite(fileName2,songg,Fs);

end