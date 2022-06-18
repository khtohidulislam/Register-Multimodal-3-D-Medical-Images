function [augVol, augVolRef] = getAugmentedVolume(vol, volRef)
% get a volume with a random rotation of [-15 15] around a random axis
% and a random translation of [-5 5] in all directions

maxAng = 15 * pi / 180;
maxTrans = 5;

% randAx = rand;
% if randAx < 1/3
%     ax = [1, 0, 0];
% elseif randAx < 2/3
%     ax = [0, 1, 0];
% else
%     ax = [0, 0, 1];
% end

ax = rand(1, 3);
randAng = 2 * rand * maxAng - maxAng;
rot = axang2rotm([ax, randAng]);
trans = 2 * maxTrans * rand(1,3) - maxTrans; 

% get augmented volume. just use the min as the fill value
%T = rigid3d([rot, zeros(3, 1); trans ,1]);
T = rigid3d(rot,trans);
[augVol, augVolRef] = imwarp(vol, volRef, T, 'bicubic', 'fillValues', min(vol(:)),'OutputView', volRef);

% c1 = round(size(vol)/2);
% c2 = round(size(augVol)/2);
% figure, imshowpair(vol(:, :, c1(3)), augVol(:, :, c2(3)));
