% This script 
global timesteps_per_year

npx = 10; % number of x-processors to use (nPx in SIZE.h)
npy = 10;  % number of y-processors to use (nPy in SIZE.h)

timesteps_per_year = 12;
snip_tc

load temp_data.mat

nx = length(x_mesh_mid);
ny = length(y_mesh_mid);

% size of "padding" cells to ensure all tiles are same size
gx = ceil(nx/npx) * npx - nx;
gy = ceil(ny/npy) * npy - ny;

% displays values that are needed for sNx, sNy
disp(['tile nx: ' num2str(ceil(nx/npx))]) % sNx in SIZE.h
disp(['tile ny: ' num2str(ceil(ny/npy))]) % sNx in SIZE.h
disp(['grid nx: ' num2str(nx+gx)]) % sNx in SIZE.h
disp(['grid ny: ' num2str(ny+gy)]) % sNx in SIZE.h

setup_experiment_tc(nx,ny,gx,gy);

