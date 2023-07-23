%% preprocessing resting state fMRI datasets
%% step 1:  read All images out of the GZ files
clear;clc;
rootDir='D:\Work\dataN\Session01';
subName=filename_list([rootDir],'*RUN08');
GSMmask='C:\Program Files\MATLAB\R2018a\toolbox\AMRItool\GRETNA\Mask\BrainMask_3mm.nii';
CSFmask='C:\Program Files\MATLAB\R2018a\toolbox\AMRItool\GRETNA\Mask\CSFMask_3mm.nii';
WMmask='C:\Program Files\MATLAB\R2018a\toolbox\AMRItool\GRETNA\Mask\WMMask_3mm.nii';
GMmask='C:\Program Files\MATLAB\R2018a\toolbox\AMRItool\GRETNA\Mask\GMMask_3mm.nii';

%% this process defines the batch files for each subject
for subid=1:1:length(subName)
    fpath=[subName{subid}];
    
%     %% time slicing
    imageFile={[fpath,'\nrun08.nii']};
    allBatch{subid}.jobs1{1}.temporal{1}.st.scans = {imageFile};
    allBatch{subid}.jobs1{1}.temporal{1}.st.nslices = 36;
    allBatch{subid}.jobs1{1}.temporal{1}.st.tr = 2;
    allBatch{subid}.jobs1{1}.temporal{1}.st.ta =2-2/36;
    allBatch{subid}.jobs1{1}.temporal{1}.st.so = [2:2:36 1:2:35];
    allBatch{subid}.jobs1{1}.temporal{1}.st.refslice = 1;
    allBatch{subid}.jobs1{1}.temporal{1}.st.prefix = 'a'; 
    
%     %% head motion correction
    imageFile={[fpath,'\anrun08.nii']};
    allBatch{subid}.jobs2{1}.spatial{1}.realign{1}.estwrite.data = {imageFile};
    allBatch{subid}.jobs2{1}.spatial{1}.realign{1}.estwrite.roptions.prefix = 'r';
%     
%     %% segment
    imageFile={[fpath,'\meananrun08.nii']};
    allBatch{subid}.jobs3{1}.spatial{1}.preproc.channel.vols = imageFile;
    allBatch{subid}.jobs3{1}.spatial{1}.preproc.warp.affreg = 'mni';
    allBatch{subid}.jobs3{1}.spatial{1}.preproc.warp.write = [0 1];

%     %% normalize
    imageFile={[fpath,'\y_meananrun08.nii']};
    imageFile2={[fpath,'\ranrun08.nii']};
    allBatch{subid}.jobs4{1}.spatial{1}.normalise{1}.write.subj.def = imageFile;
    allBatch{subid}.jobs4{1}.spatial{1}.normalise{1}.write.subj.resample = imageFile2;
    allBatch{subid}.jobs4{1}.spatial{1}.normalise{1}.write.woptions.bb = [-90 -126 -72 90 90 108];   % two point in MNI
    allBatch{subid}.jobs4{1}.spatial{1}.normalise{1}.write.woptions.vox = [3 3 3];   % voxel volume
    allBatch{subid}.jobs4{1}.spatial{1}.normalise{1}.write.woptions.interp = 1;
 
%   % spatial moothing
    imageFile={[fpath,'\wranrun08.nii']};
    allBatch{subid}.jobs5{1}.spatial{1}.smooth.data = imageFile;
    allBatch{subid}.jobs5{1}.spatial{1}.smooth.fwhm = [6 6 6];

end

for subid=1:1:length(subName)
    fpath=[subName{subid}];
    % cd(fpath);
    imageFile={[fpath,'\run08.nii']};    
    gretna_RUN_RmFstImg(imageFile,10);
    spm_jobman('run',allBatch{subid}.jobs1);
    toDelete=filename_list(fpath,'nr*.nii');
    delete(toDelete{1});

    spm_jobman('run',allBatch{subid}.jobs2);
    toDelete=filename_list(fpath,'an*.nii');
    delete(toDelete{1});

    spm_jobman('run',allBatch{subid}.jobs3)
    spm_jobman('run',allBatch{subid}.jobs4)

    toDelete=filename_list(fpath,'ran*.nii');
    delete(toDelete{1});

    spm_jobman('run',allBatch{subid}.jobs5)
  
    toDelete=filename_list(fpath,'wran*.nii');
    delete(toDelete{1});
    
    imageFile=filename_list(fpath,'swr*.nii');
    gretna_RUN_Detrend(imageFile, 0);
    delete(imageFile{1});

    
     
%% prepare files for nutrianse regressor
    imageFile={[fpath,'\dswranrun08.nii']};
    struFit=spm_vol(imageFile{1});
    resizeNifiti(GSMmask,[fpath,'\GSMmask.nii'],struFit(1));
    resizeNifiti(WMmask,[fpath,'\WMmask.nii'],struFit(1));
    resizeNifiti(CSFmask,[fpath,'\CSFmask.nii'],struFit(1));
    hdFile=filename_list(fpath,'rp*.txt');
    gretna_RUN_RegressOut(imageFile,[fpath,'\GSMmask.nii'],[fpath,'\WMmask.nii'], [fpath,'\CSFmask.nii'],3,hdFile);
    toDelete=filename_list(fpath,'dswran*.nii');
    delete(toDelete{1});
    
    
    imageFile={[fpath,'\cWGSdswranrun08.nii']};
    gretna_RUN_Filter(imageFile,2,[0.01 0.1]);
    delete(imageFile{1});
    
end





function[] = resizeNifiti(imageName,writeName,toFitStructure)
%% resize nifiti images
%% imageName image name to resize;writePath path to save new nifiti;
%% toFitStructure,headfile of target size to fit
image=spm_read_vols(spm_vol(imageName));
image=BrainTop_RealCoorTrans(toFitStructure.dim,image);
toFitStructure.fname=writeName;
spm_write_vol(toFitStructure,image);
end