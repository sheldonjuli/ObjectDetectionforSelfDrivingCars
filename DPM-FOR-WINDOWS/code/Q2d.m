globals;
addpath('dpm') ;
addpath('devkit') ;

general_data = getData([], 'test', 'list');
ids = general_data.ids;

for i = 1 : length(ids)

    id = string(ids(i));
    
    cam_params = getData(id, 'test', 'calib');

    imdata = getData(id, 'test', 'left');
    depth_data = getData(id, [], 'load-depth-result');
    depth = depth_data.depth;
    
    detector_data = getData(id, [], 'load-detector-result');

    [top_car_ds, top_car_bs] = getTopDetection(detector_data.ds_car.ds_car, detector_data.bs_car.bs_car);
    [top_cyclist_ds, top_cyclist_bs] = getTopDetection(detector_data.ds_cyclist.ds_cyclist, detector_data.bs_cyclist.bs_cyclist);
    [top_person_ds, top_person_bs] = getTopDetection(detector_data.ds_person.ds_person, detector_data.bs_person.bs_person);

    car_locations = computeLocations(top_car_ds, top_car_bs, depth, cam_params);
    save(char(strcat(LOCATION_RESULT_DIR, '/', id, '_car_location.mat')), 'car_locations');
    person_locations = computeLocations(top_person_ds, top_person_bs, depth, cam_params);
    save(char(strcat(LOCATION_RESULT_DIR, '/', id, '_person_location.mat')), 'person_locations');
    cyclist_locations = computeLocations(top_cyclist_ds, top_cyclist_bs, depth, cam_params);
    save(char(strcat(LOCATION_RESULT_DIR, '/', id, '_cyclist_location.mat')), 'cyclist_locations');

end

function [top_ds, top_bs] = getTopDetection(ds, bs)

    f = 1.5;
    nms_thresh = 0.5;
    
    top_ds = [];
    top_bs = [];

    if ~isempty(ds)
        top = nms(ds, nms_thresh);
        ds(:, 1:end-2) = ds(:, 1:end-2)/f;
        bs(:, 1:end-2) = bs(:, 1:end-2)/f;
        
        top_ds = ds(top,:);
        top_bs = bs(top,:);
    end
    
end

function locations = computeLocations(ds, bs, depth, cam_params)

    f = cam_params.f;
    px_d = cam_params.K(1, 3);
    py_d = cam_params.K(2, 3);
    
    locations = [];
    [row_count, col_count] = size(ds);
    for i = 1 : row_count
        single_ds = ds(i,:);
        x_mid = (single_ds(1, 3) + single_ds(1, 1)) / 2;
        y_mid = (single_ds(1, 4) + single_ds(1, 2)) / 2;
        Z = depth(int16(y_mid), int16(x_mid));
        X = (Z / f) * (x_mid - px_d);
        Y = (Z / f) * (y_mid - py_d);
        locations = [locations; X, Y, Z];
    end

end