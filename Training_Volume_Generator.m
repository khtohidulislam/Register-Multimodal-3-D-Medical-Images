clear all
close all
%Loading Directory
fixedRefArray='E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\NewVomumesAndRef\Rfixed';
fixedVolArray='E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\NewVomumesAndRef\fixedVolume';
movingRefArray='E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\NewVomumesAndRef\Rmoving';
movingVolArray='E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\NewVomumesAndRef\movingVolume';

%Reading Image Datastore
fixedRefArray = imageDatastore(fixedRefArray,'FileExtensions','.mat','ReadFcn',@matRead);
fixedVolArray = imageDatastore(fixedVolArray,'FileExtensions','.mat','ReadFcn',@matRead);
movingRefArray = imageDatastore(movingRefArray,'FileExtensions','.mat','ReadFcn',@matRead);
movingVolArray = imageDatastore(movingVolArray,'FileExtensions','.mat','ReadFcn',@matRead);

% Define Number of Files/Images
nFiles = numel(fixedRefArray.Files);
%%
volumeNumber=16;

% get world references
fixedVolume = matRead(fixedVolArray.Files{volumeNumber});
movingVolume = matRead(movingVolArray.Files{volumeNumber});
fixedRef=matRead(fixedRefArray.Files{volumeNumber});
movingRef = matRead(movingRefArray.Files{volumeNumber});

%fixedRef  = imref3d(size(fixedVolume), fixedHeader.PixelSize(2), fixedHeader.PixelSize(1), fixedHeader.SliceThickness);
%movingRef  = imref3d(size(movingVolume), movingHeader.PixelSize(2), movingHeader.PixelSize(1), movingHeader.SliceThickness);
%% generate some augmented data
%disp('Generating synthetic data');
nRep = 100;
fixedVolArray = cell(1, nRep);
fixedRefArray = cell(1, nRep);
movingVolArray = cell(1, nRep);
movingRefArray = cell(1, nRep);

% keep the original volumes as the first elements
fixedVolArray{1} = fixedVolume;
fixedRefArray{1} = fixedRef;
movingVolArray{1} = movingVolume;
movingRefArray{1} = movingRef;

% reset random counter so that we get the same data every time
rng('default')
h = waitbar(0,'Please wait...Generating synthetic data');
for idx = 2:nRep
    [fixedVolArray{idx}, fixedRefArray{idx}] = getAugmentedVolume(fixedVolume, fixedRef);
    [movingVolArray{idx}, movingRefArray{idx}] = getAugmentedVolume(movingVolume, movingRef);
    waitbar(idx / nRep)
end
close(h)
%%
h = waitbar(0,'Please wait...Saving synthetic data');
for fIdx = 1:nRep
    fixedVolArrayImages = fixedVolArray{fIdx};
    fixedRefArrayImages = fixedRefArray{fIdx};
    movingVolArrayImages = movingVolArray{fIdx};
    movingRefArrayImages = movingRefArray{fIdx};
    baseFileName = sprintf('_%06d.mat', fIdx);
    baseFileName = [num2str(volumeNumber), baseFileName];
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\fixedVolArray', baseFileName);
    save (fullFileName,'fixedVolArrayImages');
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\fixedRefArray', baseFileName);
    save (fullFileName,'fixedRefArrayImages');
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\movingVolArray', baseFileName);
    save (fullFileName,'movingVolArrayImages');
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\movingRefArray', baseFileName);
    save (fullFileName,'movingRefArrayImages');
    waitbar(fIdx / nRep)
end
close(h)
