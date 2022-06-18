clear all
close all
%Loading Directory
fixedRefArray='E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\fixedRefArray';
fixedVolArray='E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\fixedVolArray';
movingRefArray='E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\movingRefArray';
movingVolArray='E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\movingVolArray';

%Reading Image Datastore
fixedRefArray = imageDatastore(fixedRefArray,'FileExtensions','.mat','ReadFcn',@matRead);
fixedVolArray = imageDatastore(fixedVolArray,'FileExtensions','.mat','ReadFcn',@matRead);
movingRefArray = imageDatastore(movingRefArray,'FileExtensions','.mat','ReadFcn',@matRead);
movingVolArray = imageDatastore(movingVolArray,'FileExtensions','.mat','ReadFcn',@matRead);

% Define Number of Files/Images
nFiles = numel(fixedRefArray.Files);

h = waitbar(0,'Please wait...Saving data...');
for fIdx = 1:nFiles
    DatafixedRefArray = matRead(fixedRefArray.Files{fIdx});
    DatafixedVolArray = matRead(fixedVolArray.Files{fIdx});
    DatamovingRefArray = matRead(movingRefArray.Files{fIdx});
    DatamovingVolArray = matRead(movingVolArray.Files{fIdx});
    
    [transFixedVolArray, transFixedVolArrayRef, TFixed, symSlicesFixed] = reorientVolume(DatafixedVolArray, DatafixedRefArray);
    [transMovingVolArray, transMovingVolArrayRef, TMoving, symSlicesMoving] = reorientVolume(DatamovingVolArray, DatamovingRefArray);
    baseFileName = sprintf('%06d.mat', fIdx);
    %Define Saving Directory
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\transFixedVolArray', baseFileName);
    save (fullFileName,'transFixedVolArray');
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\transFixedVolArrayRef', baseFileName);
    save (fullFileName,'transFixedVolArrayRef');
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\TFixed', baseFileName);
    save (fullFileName,'TFixed');
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\transMovingVolArray', baseFileName);
    save (fullFileName,'transMovingVolArray');
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\transMovingVolArrayRef', baseFileName);
    save (fullFileName,'transMovingVolArrayRef');
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\TMoving', baseFileName);
    save (fullFileName,'TMoving');
    
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\transFixedVolArrayRef', baseFileName);
    save (fullFileName,'transFixedVolArrayRef');
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\transMovingVolArrayRef', baseFileName);
    save (fullFileName,'transMovingVolArrayRef');
    
    symSlicesFixed=uint8(255*mat2gray(symSlicesFixed));
    symSlicesMoving=uint8(255*mat2gray(symSlicesMoving));
    baseFileNamePNG = sprintf('%06d.png', fIdx);
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\symSlicesFixed', baseFileNamePNG);
    imwrite(symSlicesFixed, fullFileName);
    fullFileName = fullfile('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\3D Registration\augmentAndLabelData\symSlicesMoving', baseFileNamePNG);
    imwrite(symSlicesMoving, fullFileName);
    waitbar(fIdx / nFiles)
end
close(h)