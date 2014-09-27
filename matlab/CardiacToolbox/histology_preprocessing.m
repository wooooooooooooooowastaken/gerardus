function [imref, im] = histology_preprocessing(imref, im)
% histology_preprocessing  Prepare slices for intra-histology registration.
%
% histology_preprocessing converts two histology images to grayscale,
% inverts and thresholds (so that the background is black instead of
% white), extends the histograms to cover the dynamic range, and then
% matches the histograms. This prepares them to be registered.
%
% [IMREF2, IM2] = histology_preprocessing(IMREF, IM)
%
%   IMREF, IM are two input histology images (in RGB or grayscale format).
%   When histograms are matched, IM is matched to IMREF.
%
%   IMREF2, IM2 are the output images after preprocessing.
%
% See also: histology_intraframe_reg.

% Author: Ramon Casero <rcasero@gmail.com>
% Copyright © 2014 University of Oxford
% Version: 0.1.0
% $Rev$
% $Date$
% 
% University of Oxford means the Chancellor, Masters and Scholars of
% the University of Oxford, having an administrative office at
% Wellington Square, Oxford OX1 2JD, UK. 
%
% This file is part of Gerardus.
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details. The offer of this
% program under the terms of the License is subject to the License
% being interpreted in accordance with English Law and subject to any
% action against the University of Oxford being under the jurisdiction
% of the English Courts.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% check arguments
narginchk(2, 2);
nargoutchk(0, 2);

% invert image intensities
im = individual_image_preprocessing(im);
imref = individual_image_preprocessing(imref);

% match histograms to the central slice
idxref = imref > 0;

idx = im > 0;
im(idx) = imhistmatch(im(idx), imref(idxref));

end

function im = individual_image_preprocessing(im)

% convert to grayscale
if (size(im, 3) == 3)
    im = rgb2gray(im);
end

% the image should have two types of blackground pixels: white-ish and
% pure black. The white-ish ones are from the original image, and the black
% ones come from the B-spline fill-in. When we invert the image, we don't
% want to invert the black ones, so we select non-black pixels
idx = im ~= 0;

% invert image and make lowest intensity = 0
im(idx) = max(im(idx)) - im(idx);

% remove background by zeroing anything <= mode (the background forms the
% largest peak). We are quite conservative here in terms of keeping all the
% tissue we can, to avoid losing detail, even if that means that we are
% going to have a bit of background noise
im(im <= mode(double(im(idx)))) = 0;

% extend histogram to cover whole dynamic range
minh = double(min(im(im > 0)));
maxh = double(max(im(im > 0)));
im = uint8(255 * (double(im) - minh) / (maxh - minh));

end