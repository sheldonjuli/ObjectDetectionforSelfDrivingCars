
globals;
addpath('../data/test/results/');

data = getData([], 'test', 'list');
ids = data.ids(1:3);

for i = 1 : length(ids)
    id = string(ids(i));
    cam_params = getData(id, 'test', 'calib');
    numerator = cam_params.f * cam_params.baseline;
    
    
    img_disp_o = imread(char(strcat(id, '_left_disparity.png')));
    img_disp = getData(id,'test','disp');
    disp = img_disp.disparity;
    
    [n, m] = size(disp);
    depth = zeros(n, m);

    for y = 1 : n
        for x = 1 : m
            depth(y, x) = numerator / disp(y, x);
        end
    end
    
    save(char(strcat(DEPTH_RESULT_DIR, '/', id, '_depth.mat')), 'depth');
    
    depth(depth > 50) = 0;
    figure, surf(depth, 'LineStyle', 'none');
    figure, imshow(img_disp_o);
end

