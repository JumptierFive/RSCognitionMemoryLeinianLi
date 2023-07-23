%% extract 7 ROIs
% hMT/V5 47 -72 1
% LOC 46 -78 2
% aSPL 36 -45 44
% pSPL 38 -64 32
% FEF 38 0 60
% aDLPFC 44 50 10
% pDLPFC 48 24 9
clear all;
clc;
rootDir='D:\Work\dataN\';
% make seven ROIs template
niHead=spm_vol([rootDir,'Session01\sub01Rest\bcWGSdswranrest.nii']);
image=spm_read_vols(niHead(1,:));
image(:,:,:)=0;
coorROI=[-47 -72 1;-46 -78 2;-36 -45 44;-38 -64 32;-38 0 60;-44 50 10;-48 24 9];
allXYZcoors={};
for i=1:1:7
    % coorXYZ=mni2xyz(niHead(1),coorROI(i,:));
    coorXYZ=mni2cor(coorROI(i,:),niHead(1).mat);
    coorXYZroi=ROIcoors(niHead(1),coorXYZ,9/3);
    tempImage=image;
    for ki=1:1:length(coorXYZroi(:,1))
        tempImage(coorXYZroi(ki,1),coorXYZroi(ki,2),coorXYZroi(ki,3))=1;
    end
    header=niHead(1);
    header.fname=['ROI_left',num2str(i),'.nii'];
    spm_write_vol(header,tempImage);
    allXYZcoors{i}=tempImage;
end
outputDir=['D:\Work\dataN\timeSeriesS02\'];mkdir(outputDir);
allFiles=filename_list([rootDir,'Session02'],'sub*rest');
for i=1:1:length(allFiles)
    disp(['subid_',dec2base(i,10,2),'  start']);
    subTS=[];
    strN=spm_vol([allFiles{i},'\bcWGSdswranrest.nii']);
    for sti=1:1:length(strN)
        vols=spm_read_vols(strN(sti));
        tempN=[];
        for bgi=1:1:length(allXYZcoors)
            sumM=sum(sum(sum(vols.*allXYZcoors{bgi})))/sum(sum(sum(allXYZcoors{bgi})));
            tempN=[tempN,sumM];
        end
        subTS=[subTS;tempN];
    end
    save([outputDir,'sub_',dec2base(i,10,2),'Left.mat'],'subTS');
end


function [XYZcoOrds] = mni2xyz(vol,MNIcoOrds)

[m n] = size(MNIcoOrds);
if n > m
    MNIcoOrds = MNIcoOrds';
end

XYZcoOrds = round(inv(vol.mat)*[MNIcoOrds; 1]);
end

function [coordinates] = ROIcoors(vol,coorXYZ,distance)
coordinates=[];
for i=1:1:vol.dim(1)
    for k=1:1:vol.dim(2)
        for j=1:1:vol.dim(3)
            if ((i-coorXYZ(1))^2+(k-coorXYZ(2))^2+(j-coorXYZ(3))^2)<distance^2
                coordinates=[coordinates;[i,k,j]];
            end
        end
    end
end
end


function coordinate = mni2cor(mni, T)

if isempty(mni)
    coordinate = [];
    return;
end

if nargin == 1
	T = ...
        [-4     0     0    84;...
         0     4     0  -116;...
         0     0     4   -56;...
         0     0     0     1];
end

coordinate = [mni(:,1) mni(:,2) mni(:,3) ones(size(mni,1),1)]*(inv(T))';
coordinate(:,4) = [];
coordinate = round(coordinate);
end