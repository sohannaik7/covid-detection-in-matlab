clc;
clear all;
global I
global filename
global total_img
%arraydata = [0,0,0,0,0,0,0,0,0,0,0,0,0];
classlabel = [1,2];
arraydata = [];

img_folder = 'E:\SJCE\5th sem\covid 19 research papers\trainingcovid';
filename = dir(fullfile(img_folder, '*png'));
total_img = numel(filename);
g1 = 1;

img_folder2 = 'E:\SJCE\5th sem\covid 19 research papers\trainingnon';
filename2 = dir(fullfile(img_folder, '*png'));
total_img2 = numel(filename);
g2 = 2;



% here i am calling this funtion to get the sample feature of coivid by
% sending filename,emplty array, total ima ROOMAN WILL ADD DIFFERENT VALUE 
fea = mysmallfunction(filename,total_img,img_folder,arraydata,g1);
%data = fea.';
%disp(data);
%plot(fea);
arraydata = fea;
% this is for non covid
fea2 = mysmallfunction(filename,total_img,img_folder,arraydata,g2);
data = fea2.';
disp(data);
surf(data);
colorbar('AxisLocation','In');


m1 = [0,0,0,0,0,0,1,1,1,1,1,1];%----parameter to fnd the ecludean distance
m2 = [1,1,0,0,1,1,0,0,1,1,0,1];


% calculating the ecludean distanace 
eqsum = 0;%too add the value 
%(q-p)^2

for j = 1:10
    eqsum = 0;
    V = data(:,j);
    for i = 1:11
        eqsum = (m1(i)-V(i))^2;
    end
disp(eqsum);
end

global a
[path, nofile] = imgetfile();

if nofile
    magbox(sprintf('Image not found'),'ERROR', 'WARNING');
    return
end

a = imread(path);
 
% numberOfColorBands should be = 1.
[rows, columns, numberOfColorChannels] = size(a);
if numberOfColorChannels > 1%converting gray
  a = rgb2gray(a); 
end
 
 
 imData = reshape(a,[],1);
 imData = double(imData);
 [IDX nn] = kmeans(imData,4);
 imIDX = reshape(IDX, size(a));
 
 figure, 
    imshow(imIDX, []),title('Lungs image');
     
  
   bw = (imIDX==2);
   se = ones(5);
   bw = imopen(bw, se);
   bw = bwareaopen(bw,400);
   figure,
   imshow(bw);
   
   
   [R C] = size(bw)
   
   for i = 1:R
       for j=1:C
           if bw(i,j) == 1
               Out(i,j) = a(i,j);
           else
               Out(i,j) = 0;
           end 
       end
   end
  figure;
  imshow(Out,[])
   figure,
    subplot(3,2,1),imshow(imIDX==1, []);
        subplot(3,2,2),imshow(imIDX==2, []);
            subplot(3,2,3),imshow(imIDX==3, []);
                subplot(3,2,4),imshow(imIDX==4, []);
 
                
                
            
                
                
 %..................................function to find the feature.............................


function [fea] = mysmallfunction(filename,total_img,img_folder,arraydata,classval)
for n = 1:total_img
    f = fullfile(img_folder, filename(n).name);
    img = imread(f);
    img = imresize(img,[250,250]);
    
    img =  im2double(img);
    I = img;
    level = graythresh(I);
    img = im2bw(I,.6);
    img = bwareaopen(img,80); 
    img2 = im2bw(I);

    signal1 = img2(:,:);
        [cA1,cH1,cV1,cD1] = dwt2(signal1,'db4');
        [cA2,cH2,cV2,cD2] = dwt2(cA1,'db4');
        [cA3,cH3,cV3,cD3] = dwt2(cA2,'db4');
        
        DWT_feat = [cA3,cH3,cV3,cD3];
        G = pca(DWT_feat);
        whos DWT_feat
        whos G
        
        
        g = graycomatrix(G);
        stats = graycoprops(g,'Contrast Correlation Energy Homogeneity');
        Contrast = stats.Contrast;
        Correlation = stats.Correlation;
        Energy = stats.Energy;
        Homogeneity = stats.Homogeneity;
        Mean = mean2(G);
        Standard_Deviation = std2(G);
        Entropy = entropy(G);
        RMS = mean2(rms(G));
        %Skewness = skewness(img)
        Variance = mean2(var(double(G)));
        a = sum(double(G(:)));
        Smoothness = 1-(1/(1+a));
        Kurtosis = kurtosis(double(G(:)));
        Skewness = skewness(double(G(:)));

        m = size(G,1);
        n = size(G,2);
        in_diff = 0;
        for i = 1:m
            for j = 1:n
                temp = G(i,j)./(1+(i-j).^2);
                in_diff = in_diff+temp;
            end
        end
        IDM = double(in_diff);
        
        if classval == 1
            feat = [Contrast,RMS,Variance,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Smoothness, Skewness, IDM,1];    
        else
            feat = [Contrast,RMS,Variance,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Smoothness, Skewness, IDM,2];    
        end 
        arraydata = cat(1,arraydata,feat);
    end
fea = arraydata;% returning the data
end
%disp(b);
%contourf(b);
%colorbar('value');

 
