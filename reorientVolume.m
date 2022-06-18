function [transVol, transVolRef, T, symSlice] = reorientVolume(vol, volRef)

origVol = vol;
origSz = size(origVol);

% rescale volume
nRows = origSz(1);
nCols = round(origSz(2) * volRef.PixelExtentInWorldX / volRef.PixelExtentInWorldY);
nSlices = round(origSz(3) * volRef.PixelExtentInWorldZ / volRef.PixelExtentInWorldY);
sz = [nRows, nCols, nSlices];
vol = imresize3(vol, sz);

% threshold used to check if the rotation direction needs to be changed
angThresh = pi / 1800;

% get point cloud from volume
thresh = multithresh(vol(:), 2);
ind = intersect(find(vol > thresh(1)), find(vol < thresh(2)));
[y, x, z] = ind2sub(size(vol), ind);
pts = [x, y, z]; % to make it zero indexed
ctr = mean(pts);

% get symmetry axes (using symmetry or PCA)
%[~, symAxes, ~, ~] = symmetryViaRegistration3D(pts);
symAxes = pca(pts);

% extract symmetry axes
ax1 = symAxes(:, 1); 
ax2 = symAxes(:, 2);
ax3 = symAxes(:, 3);

% if not unit vectors, make them so
if norm(ax1) ~= 1
    ax1 = ax1 / norm(ax1);
    ax2 = ax2 / norm(ax2);
    ax3 = ax3 / norm(ax3);
end

% define the original axes
xAx = [1; 0; 0];
yAx = [0; 1; 0];
zAx = [0; 0; 1];

% first rotation is to get ax1 aligned with the y axis. this is a rotation
% around the normal to both y and ax1.
rotAng1 = acos(dot(yAx, ax1));
rotAx1 = cross(yAx, ax1) / sin(rotAng1);
R1 = axang2rotm([rotAx1' rotAng1]);

% check rotation direction
if acos(dot(ax1, R1 * yAx)) > angThresh
    R1 = axang2rotm([rotAx1', -rotAng1]);
end

% get the vectors denoting the original x axis after this rotation
xNew = R1 * xAx;

% now, to rotate the x and z axes to align with ax2 and ax3, we have to
% find the angle between the new x and ax2. rotation axis is ax1 (or new y).
rotAng2 = acos(dot(xNew, ax2));
R2 = axang2rotm([ax1', rotAng2]);

% check rotation direction 
if acos(dot(ax2, R2 * xNew)) > angThresh
    R2 = axang2rotm([ax1', -rotAng2]);
end

% get full transormation
R = R2*R1;

imgCtr = [mean(volRef.XWorldLimits), mean(volRef.YWorldLimits), mean(volRef.ZWorldLimits)];
realCtr = (ctr - 1) * volRef.PixelExtentInWorldY + [volRef.XWorldLimits(1), volRef.YWorldLimits(1), volRef.ZWorldLimits(1)];

T1 = rigid3d(eye(3), - realCtr);
T2 = rigid3d(R, zeros(1, 3));
T3 = rigid3d(eye(3), imgCtr);
T = rigid3d();
T.T = T1.T * T2.T * T3.T;

fillVal = min(origVol(:));
[transVol, transVolRef] = imwarp(origVol, volRef, T, 'bicubic', 'fillValues', fillVal, 'OutputView', volRef);

% get symmetry slice
ctrVol = round(size(transVol) / 2);
symSlice = transVol(:, :, ctrVol(3));

% %% testing
% transVolTest = fillVal * ones(sz);
% transCtr = (1 + [sz(2), sz(1), sz(3)])' / 2; % because matlab has 1-indexing
% 
% for rowIdx = 1:sz(1)
%     for colIdx = 1:sz(2)
%         for slcIdx = 1:sz(3)
%             pt = [colIdx; rowIdx; slcIdx];
%             rotPt = R * (pt - transCtr) + ctr';
%             volIdx = round([rotPt(2), rotPt(1), rotPt(3)]);
%             
%             if volIdx(1) >= 1 && volIdx(1) <= sz(1) && ...
%                volIdx(2) >= 1 && volIdx(2) <= sz(2) && ...
%                volIdx(3) >= 1 && volIdx(3) <= sz(3)
%                     volInt = vol(volIdx(1), volIdx(2), volIdx(3));
%                     transVolTest(rowIdx, colIdx, slcIdx) = volInt;
%             end
%         end
%     end
% end
% 
% % go back to the size of the original volume
% transVolTest = imresize3(transVolTest, origSz);
% 
% figure, subplot(1, 3, 1), imagesc(origVol(:, :, ctrVol(3))), title('Original');
% subplot(1, 3, 2), imagesc(transVol(:, :, ctrVol(3))), title('PCA');
% subplot(1, 3, 3), imagesc(transVolTest(:, :, ctrVol(3))), title('Test');


% % see if this rotation brough the axes to the new system
% xDiff = norm(ax1 - R*[1; 0; 0])
% yDiff = norm(ax2 - R*[0; 1; 0])
% zDiff = norm(ax3 - R*[0; 0; 1])
% 
% % compare the original and transformned images
% figure, subplot(1, 3, 1), imshowpair(transVolTest(:, :, ctrVol(3)), transVol(:, :, ctrVol(3)));
% subplot(1, 3, 2), imshowpair(squeeze(transVolTest(:, ctrVol(2), :)), squeeze(transVol(:, ctrVol(2), :)));
% subplot(1, 3, 3), imshowpair(squeeze(transVolTest(ctrVol(1), :, :)), squeeze(transVol(ctrVol(1), :, :)));
% figure, imagesc(transVolTest(:, :, ctrVol(3)));


% % see if the symmetry axes are aligned with the data
% idx = 1:100:size(pts, 1);
% pts = pts(idx, :);
% transPts = (R'*(pts - ctr)')' + ctr;
% d = 200;
% 
% figure, hold on;
% plot3(pts(:, 1), pts(:, 2), pts(:, 3), 'k.');
% plot3([ctr(1) ctr(1)+d], [ctr(2) ctr(2)], [ctr(3) ctr(3)], 'r-');
% plot3([ctr(1) ctr(1)], [ctr(2) ctr(2)+d], [ctr(3) ctr(3)], 'g-');
% plot3([ctr(1) ctr(1)], [ctr(2) ctr(2)], [ctr(3) ctr(3)+d], 'b-');
% plot3([ctr(1) ctr(1)+ax1(1)*d], [ctr(2) ctr(2)+ax1(2)*d], [ctr(3) ctr(3)+ax1(3)*d], 'm--');
% plot3([ctr(1) ctr(1)+ax2(1)*d], [ctr(2) ctr(2)+ax2(2)*d], [ctr(3) ctr(3)+ax2(3)*d], 'y--');
% plot3([ctr(1) ctr(1)+ax3(1)*d], [ctr(2) ctr(2)+ax3(2)*d], [ctr(3) ctr(3)+ax3(3)*d], 'c--');
% 
% axis equal;
% 
% figure, hold on, axis equal;
% plot3(transPts(:, 1), transPts(:, 2), transPts(:, 3), 'k.');
% plot3([ctr(1) ctr(1)+d], [ctr(2) ctr(2)], [ctr(3) ctr(3)], 'r-');
% plot3([ctr(1) ctr(1)], [ctr(2) ctr(2)+d], [ctr(3) ctr(3)], 'g-');
% plot3([ctr(1) ctr(1)], [ctr(2) ctr(2)], [ctr(3) ctr(3)+d], 'b-');
% axis equal;

% xNew = R1 * xAx;
% zNew = R1 * zAx;
% plot3([ctr(1) ctr(1)+xNew(1)*d], [ctr(2) ctr(2)+xNew(2)*d], [ctr(3) ctr(3)+xNew(3)*d], 'r:');
% plot3([ctr(1) ctr(1)+yNew(1)*d], [ctr(2) ctr(2)+yNew(2)*d], [ctr(3) ctr(3)+yNew(3)*d], 'g:');
% plot3([ctr(1) ctr(1)+zNew(1)*d], [ctr(2) ctr(2)+zNew(2)*d], [ctr(3) ctr(3)+zNew(3)*d], 'b:');



