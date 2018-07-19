
globals;
addpath('dpm') ;
addpath('devkit') ;

general_data = getData([], 'test', 'list');
ids = general_data.ids(1:3);
data_car = getData([], [], 'detector-car');
models_car = data_car.model;
data_cyclist = getData([], [], 'detector-bicycle');
models_cyclist = data_cyclist.model;
data_person = getData([], [], 'detector-person');
models_person = data_person.model;

for i = 1 : length(ids)

    id = string(ids(i));

    imdata = getData(id, 'test', 'left');
    data = getData(id, [], 'load-detector-result');
    
    figure(i), imshow(imdata.im);
    showDetection(imdata.im, models_car, data.ds_car.ds_car, data.bs_car.bs_car, 'r')
    showDetection(imdata.im, models_cyclist, data.ds_cyclist.ds_cyclist, data.bs_cyclist.bs_cyclist, 'c')
    showDetection(imdata.im, models_person, data.ds_person.ds_person, data.bs_person.bs_person, 'b')

end

function showDetection(im, model, ds, bs, col)

    f = 1.5;
    nms_thresh = 0.5;
    
    if ~isempty(ds)
        top = nms(ds, nms_thresh);
        ds(:, 1:end-2) = ds(:, 1:end-2)/f;
        bs(:, 1:end-2) = bs(:, 1:end-2)/f;
        showboxesMy(im, reduceboxes(model, bs(top,:)), col);
    end

end
