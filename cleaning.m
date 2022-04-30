% Usage clean_img = cleaning(orig_img)
%
% orig_img - rgb image of sticks for which we want to compute an order
%
% clean_img - orig_img converted to a binary image and cleaned of noise
function clean_img = cleaning(orig_img)

%first convert to grayscale
gray_img = rgb2gray(orig_img);

bw_img = imbinarize(gray_img, 'adaptive', 'ForegroundPolarity', 'bright', 'Sensitivity', 0.50);

processed_img = bw_img;
%figure; imshow(processed_img);

k1 = 2;
% clean noise on the sticks
processed_img = bwmorph(processed_img, 'dilate', k1);
processed_img = bwmorph(processed_img, 'erode', k1);
%figure; imshow(processed_img);

k2 = 1;
% clean noise on the background
processed_img = bwmorph(processed_img, 'erode', k2);
processed_img = bwmorph(processed_img, 'dilate', k2);
%figure; imshow(processed_img);

clean_img = processed_img;