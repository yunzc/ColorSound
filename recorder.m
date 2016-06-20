recObj = audiorecorder(44100,16,1);
disp('start recording');
recordblocking(recObj,2);
disp('stop recording');
audiofile=getaudiodata(recObj);
Fs=44100;

%create fourier transform and a conversion from index to frequency
rdft=fft(audiofile);
freq=0:Fs/length(audiofile):Fs/2;
rdft = rdft(1:floor(length(audiofile)/2)+1);
absrd=abs(rdft);

%find the top 5 harmonics and their magnitudes
harmonicval=zeros(5,1);
harmonicfreq=zeros(5,1);
for i=1:5
    [pks,locs]=findpeaks(absrd);
    [val,loc]=max(pks);
    ind = locs(loc);
    harmonicval(i)=val;
    harmonicfreq(i)=freq(ind); 
    absrd(ind)=0;
end
display(harmonicfreq);

imm=zeros(1000,1000,3);
%convert from freq to RGB [255;0;0] to [0;255;0] to [0;0;255]
pixelval = zeros(5,1,3);

for i=1:5
    frequ=harmonicfreq(i);
    %up to 10 octaves from C_0
    for j=1:10
        if frequ<32.70*2.^(j-1) && frequ>16.35*2.^(j-1)
            remainder = rem((frequ-16.35*2.^(j-1)),(16.35*2.^(j-1)/3));
            remainder2= rem((frequ-16.35*2.^(j-1)),(16.35*2.^(j-1)/6));
            division= floor((frequ-16.35*2.^(j-1))/(16.35*2.^(j-1)/3));
            if division < 2
                if remainder>(16.35*2.^(j-1)/6)
                    change=division+1;
                    maxi = division+2;
                else 
                    change=division+2;
                    maxi=division+1;
                end
            else
                if remainder>(16.35*(2.^(j-1))/6)
                    change=3;
                    maxi = 1;
                else 
                    change=1;
                    maxi=3;
                end
            end
            pixelval(i,1,change)=(255/(16.35*(2.^(j-1))/6))*remainder2;
            pixelval(i,1,maxi)=255;
        end
    end
end

display(pixelval(5,1,3));
%percentage of each is according to magnitude (harmonicval)
percentage = zeros(6,1);
for i = 1:5
    tot = sum(harmonicval);
    percentage(i+1,1)=floor(1000*(harmonicval(i,1)/tot));
end
cpercentage=cumsum(percentage);
remainp=1000-cpercentage(6);
cpercentage(2:6,1)=cpercentage(2:6,1)+remainp;

for i=1:1000
    rowindex=randperm(1000);
    for j=1:5
        a=pixelval(j,1,1);
        b=pixelval(j,1,2);
        c=pixelval(j,1,3);
        for k=cpercentage(j)+1:cpercentage(j+1)
            imm(i,rowindex(k),1)=a;
            imm(i,rowindex(k),2)=b;
            imm(i,rowindex(k),3)=c;
        end
    end
end
 image(imm);
 
        

