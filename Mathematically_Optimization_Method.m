% Step 1: Load Images
close all
fixedHeader  = helperReadHeaderRIRE('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\patient_001\mr_T1\header.ascii');
movingHeader = helperReadHeaderRIRE('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\patient_001\ct\header.ascii');
fixedVolume  = multibandread('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\patient_001\mr_T1\image.bin',...
                            [fixedHeader.Rows, fixedHeader.Columns, fixedHeader.Slices],...
                            'int16=>single', 0, 'bsq', 'ieee-be' );
movingVolume = multibandread('E:\PhD Chapters\Thoughts for chapter or paper 2\Database\patient_001\ct\image.bin',...
                            [movingHeader.Rows, movingHeader.Columns, movingHeader.Slices],...
                            'int16=>single', 0, 'bsq', 'ieee-be' );
sizeI=size(fixedVolume);
movingVolume2=imresize3(movingVolume,sizeI);
Input=fixedVolume+movingVolume2;
helperVolumeRegistration(fixedVolume,movingVolume);

%%
centerFixed = round(size(fixedVolume)/2);
centerMoving = round(size(movingVolume)/2);
% centerFixed = size(fixedVolume)/2;
% centerMoving = size(movingVolume)/2;
figure
imshowpair(movingVolume(:,:,centerMoving(3)), fixedVolume(:,:,centerFixed(3)));
title('Unregistered Axial Slice')

%% Step 2: Set up the Initial Registration
tic
[optimizer,metric] = imregconfig('multimodal');
Rfixed  = imref3d(size(fixedVolume),fixedHeader.PixelSize(2),fixedHeader.PixelSize(1),fixedHeader.SliceThickness);
Rmoving = imref3d(size(movingVolume),movingHeader.PixelSize(2),movingHeader.PixelSize(1),movingHeader.SliceThickness);
%Rmoving.XWorldLimits
%Rmoving.PixelExtentInWorldX
%Rmoving.ImageExtentInWorldX
optimizer.InitialRadius = 0.001;
% tic
% movingRegisteredVolume = imregister(movingVolume,Rmoving, fixedVolume,Rfixed, 'affine', optimizer, metric);
% toc
% figure
% imshowpair(movingRegisteredVolume(:,:,centerFixed(3)), fixedVolume(:,:,centerFixed(3)));
% title('Axial Slice of Registered Volume')
% helperVolumeRegistration(fixedVolume,movingRegisteredVolume);
% B=movingRegisteredVolume;
% %[MSE,PSNR,AD,SC,NK,MD,LMSE,NAE]=iq_measures(A,B)

%% Step 3: Get 3-D Geometric Transformation That Aligns Moving With Fixed.
geomtform = imregtform(movingVolume,Rmoving, fixedVolume,Rfixed, 'rigid', optimizer, metric)
geomtform.T


centerXWorld = mean(Rmoving.XWorldLimits);
centerYWorld = mean(Rmoving.YWorldLimits);
centerZWorld = mean(Rmoving.ZWorldLimits);
[xWorld,yWorld,zWorld] = transformPointsForward(geomtform,centerXWorld,centerYWorld,centerZWorld);

[r,c,p] = worldToSubscript(Rfixed,xWorld,yWorld,zWorld)
movingRegisteredVolume2 = imwarp(movingVolume,Rmoving,geomtform,'bicubic','OutputView',Rfixed);
toc
figure 
imshowpair(movingRegisteredVolume2(:,:,centerFixed(3)), fixedVolume(:,:,centerFixed(3)));
title('Axial Slice of Registered Volume')