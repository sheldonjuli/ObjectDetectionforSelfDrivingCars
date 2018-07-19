globals;
addpath('dpm') ;
addpath('devkit') ;

general_data = getData([], 'test', 'list');
ids = general_data.ids(1:3);

for i = 1 : length(ids)

    id = string(ids(i));
    
    cam_params = getData(id, 'test', 'calib');

    imdata = getData(id, 'test', 'left');
    im_o = imdata.im;
    
    depth_data = getData(id, [], 'load-depth-result');
    depth = depth_data.depth;
    
    full_lo = computeLocationsFull(im_o, depth, cam_params);
    
    lo_data = getData(id, [], 'load-location-result');

    seg_img = segImg(im_o, lo_data.lo_car.car_locations, full_lo, '1');
    seg_img = segImg(seg_img, lo_data.lo_cyclist.cyclist_locations, full_lo, '2');
    seg_img = segImg(seg_img, lo_data.lo_person.person_locations, full_lo, '3');
    
    generateDesc(id, lo_data)
    
    figure, imshow(seg_img);

end

function seg_img = segImg(im_o, location, full_location, channel)
    
    X = full_location.X;
    Y = full_location.Y;
    Z = full_location.Z;
    
    seg_img = im_o;
    if ~isempty(location)
        num_lo = size(location, 1);
        for i = 1 : num_lo
            lo = location(i, :);
            c_x = lo(1, 1);
            c_y = lo(1, 2);
            c_z = lo(1, 3);
            
            for y = 1 : size(im_o, 1)
                for x = 1 : size(im_o, 2)
                    if getSqDistance(c_x, c_y, c_z, X(y, x), Y(y, x), Z(y, x)) <= 9
                        if channel == '1'
                            seg_img(y, x, 1) = 255;
                            seg_img(y, x, 2) = 0;
                            seg_img(y, x, 3) = 0;
                        elseif channel == '2'
                            seg_img(y, x, 1) = 0;
                            seg_img(y, x, 2) = 255;
                            seg_img(y, x, 3) = 0;
                        else
                            seg_img(y, x, 1) = 0;
                            seg_img(y, x, 2) = 0;
                            seg_img(y, x, 3) = 255;
                        end
                    end
                end
            end
        end
    end
end


function full_lo = computeLocationsFull(im, depth, cam_params)
    
    f = cam_params.f;
    px_d = cam_params.K(1, 3);
    py_d = cam_params.K(2, 3);
    
    [x, y] = meshgrid(0:size(im,2)-1, 0:size(im,1)-1);
    y = size(im,1)-1-y;
    
    Z = depth;
    X = (Z / f) .* (x - px_d);
    Y = (Z / f) .* (y - py_d);
    
    full_lo.Z = Z;
    full_lo.X = X;
    full_lo.Y = Y;

end

function dist = getSqDistance(x1, y1, z1, x2, y2, z2)
    dist = (x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2;
end

function generateDesc(id, lo_data)
    lo_car = lo_data.lo_car.car_locations;
    lo_cyclist = lo_data.lo_cyclist.cyclist_locations;
    lo_person = lo_data.lo_person.person_locations;
    
    num_car = size(lo_car, 1);
    num_cyclist = size(lo_cyclist, 1);
    num_person = size(lo_person, 1);
    
    fprintf("For image %s: \n", id);
    fprintf("There are %d cars, %d people and %d cyclists ahead. \n", num_car, num_cyclist, num_person);
    
    cloest = 100;
    str = "";
    for i = 1 : num_car
        lo = lo_car(i, :);
        d = norm(lo);
        if d <= cloest
            cloest = d;
            if lo(1, 1) >= 0
            	str = sprintf("There is a car %0.1f meters to your right. \n", d);
            else
                str = sprintf("There is a car %0.1f meters to your left. \n", d);
            end

        end
    end
	for i = 1 : num_cyclist
        lo = lo_cyclist(i, :);
        d = norm(lo);
        if d <= cloest
            cloest = d;
            if lo(1, 1) >= 0
            	str = sprintf("There is a cyclist %0.1f meters to your right. \n", d);
            else
                str = sprintf("There is a cyclist %0.1f meters to your left. \n", d);
            end

        end
    end
	for i = 1 : num_person
        lo = lo_person(i, :);
        d = norm(lo);
        if d <= cloest
            cloest = d;
            if lo(1, 1) >= 0
            	str = sprintf("There is a person %0.1f meters to your right. \n", d);
            else
                str = sprintf("There is a person %0.1f meters to your left. \n", d);
            end

        end
    end
    fprintf(str);
end