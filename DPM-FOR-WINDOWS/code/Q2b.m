
globals;
addpath('dpm') ;
addpath('devkit') ;
addpath('../data/test/results/');

data = getData([], 'test', 'list');
ids = data.ids(1:3);

data_car = getData([], [], 'detector-car');
models_car = data_car.model;
data_person = getData([], [], 'detector-person');
models_person = data_person.model;
data_cyclist = getData([], [], 'detector-cyclist');
models_cyclist = data_cyclist.model;

f = 1.5;

for i = 1 : length(ids)
    id = string(ids(i));

    imdata = getData(id, 'test', 'left');
    im = imdata.im;
    imr = imresize(im,f); % if we resize, it works better for small objects

    % detect objects
    fprintf(strcat('running the detector for :', id, ', may take a few seconds...\n'));
    tic;
    %[ds, bs] = imgdetect(imr, model, model.thresh); % you may need to reduce the threshold if you want more detections
%     [ds_car, bs_car] = imgdetect(imr, models_car, 0);
%     save(char(strcat(DETECTOR_RESULT_DIR, '/', id, '_ds_car.mat')), 'ds_car');
%     save(char(strcat(DETECTOR_RESULT_DIR, '/', id, '_bs_car.mat')), 'bs_car');
    
    [ds_person, bs_person] = imgdetect(imr, models_person, 0);
    save(char(strcat(DETECTOR_RESULT_DIR, '/', id, '_ds_person.mat')), 'ds_person');
    save(char(strcat(DETECTOR_RESULT_DIR, '/', id, '_bs_person.mat')), 'bs_person');
    
%     [ds_cyclist, bs_cyclist] = imgdetect(imr, models_cyclist, -0.5);
%     save(char(strcat(DETECTOR_RESULT_DIR, '/', id, '_ds_cyclist.mat')), 'ds_cyclist');
%     save(char(strcat(DETECTOR_RESULT_DIR, '/', id, '_bs_cyclist.mat')), 'bs_cyclist');
    
    e = toc;
    fprintf('finished! (took: %0.4f seconds)\n', e);
end

