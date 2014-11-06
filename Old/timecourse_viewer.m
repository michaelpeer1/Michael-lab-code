function varargout = timecourse_viewer(varargin)
% TIMECOURSE_VIEWER MATLAB code for timecourse_viewer.fig
%      TIMECOURSE_VIEWER, by itself, creates a new TIMECOURSE_VIEWER or raises the existing
%      singleton*.
%
%      H = TIMECOURSE_VIEWER returns the handle to a new TIMECOURSE_VIEWER or the handle to
%      the existing singleton*.
%
%      TIMECOURSE_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TIMECOURSE_VIEWER.M with the given input arguments.
%
%      TIMECOURSE_VIEWER('Property','Value',...) creates a new TIMECOURSE_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before timecourse_viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to timecourse_viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help timecourse_viewer

% Last Modified by GUIDE v2.5 16-May-2013 15:09:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @timecourse_viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @timecourse_viewer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before timecourse_viewer is made visible.
function timecourse_viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to timecourse_viewer (see VARARGIN)

% Choose default command line output for timecourse_viewer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes timecourse_viewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = timecourse_viewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function T1_filename_box_Callback(hObject, eventdata, handles)
% hObject    handle to T1_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T1_filename_box as text
%        str2double(get(hObject,'String')) returns contents of T1_filename_box as a double

% --- Executes during object creation, after setting all properties.
function T1_filename_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to T1_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function func_dirname_box_Callback(hObject, eventdata, handles)
% hObject    handle to func_dirname_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of func_dirname_box as text
%        str2double(get(hObject,'String')) returns contents of func_dirname_box as a double


% --- Executes during object creation, after setting all properties.
function func_dirname_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to func_dirname_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_t1.
function load_t1_Callback(hObject, eventdata, handles)
% load the T1 image
[t1filename, t1pathname, ~] = uigetfile('*.img;*.nii');
cd(t1pathname);
handles.t1_filename=fullfile(t1pathname,t1filename);
set(handles.t1_filename_box,'String',handles.t1_filename);
handles.t1_matrix=spm_read_vols(spm_vol(handles.t1_filename));
% if functional directory already entered, reslice T1 according to func
if isfield(handles,'func_dir_filenames')
    handles.t1_matrix=y_Reslice_no_outputfile(handles.t1_filename,[],1, fullfile(handles.func_dirname,handles.func_dir_filenames(1).name));
end
guidata(hObject, handles);
% plot the 3 axes of the T1 image
sz=size(handles.t1_matrix);
handles.x=round(sz(1)/2); handles.y=round(sz(2)/2); handles.z=round(sz(3)/2);
axes(handles.x_view); imagesc(squeeze(handles.t1_matrix(handles.x,:,:)));
axes(handles.y_view); imagesc(squeeze(handles.t1_matrix(:,handles.y,:)));
axes(handles.z_view); imagesc(squeeze(handles.t1_matrix(:,:,handles.z)));

guidata(hObject, handles);

% --- Executes on button press in load_funcdir.
function load_funcdir_Callback(hObject, eventdata, handles)
% load the functional images
handles.func_dirname = uigetdir();
cd(handles.func_dirname);
set(handles.func_dirname_box,'String',handles.func_dirname);
handles.func_dir_filenames=dir(fullfile(handles.func_dirname,'*.img'));
if isempty(handles.func_dir_filenames)
    handles.func_dir_filenames=dir(fullfile(handles.func_dirname,'*.nii'));
end
if length(handles.func_dir_filenames)>1
    % for 3D files
    for i=1:length(handles.func_dir_filenames)
        handles.func_matrices(:,:,:,i)=spm_read_vols(spm_vol(fullfile(handles.func_dirname,handles.func_dir_filenames(i).name)));
    end
else
    % for one 4D file
    handles.func_matrices=spm_read_vols(spm_vol(fullfile(handles.func_dirname,handles.func_dir_filenames(1).name)));
end
% if t1 image already entered, reslice T1 according to func
if isfield(handles,'t1_filename')
    handles.t1_matrix=y_Reslice_no_outputfile(handles.t1_filename,[],1, fullfile(handles.func_dirname,handles.func_dir_filenames(1).name));
end
guidata(hObject, handles);


% --- Executes on button press in change_x.
function change_x_Callback(hObject, eventdata, handles)
axes(handles.x_view); 
[z,y]=ginput(1);
handles.y=round(y); handles.z=round(z);
axes(handles.y_view); imagesc(squeeze(handles.t1_matrix(:,handles.y,:)));
axes(handles.z_view); imagesc(squeeze(handles.t1_matrix(:,:,handles.z)));
guidata(hObject, handles);
% plotting the time-course of the voxel
if isfield(handles,'func_dir_filenames')
    axes(handles.timecourse_plot);
    plot([1:10;1:2:20])
    %plot(squeeze(handles.func_matrices(handles.x,handles.y,handles.z,:)));
end

% --- Executes on button press in change_y.
function change_y_Callback(hObject, eventdata, handles)
axes(handles.y_view); 
[z,x]=ginput(1);
handles.x=round(x); handles.z=round(z);
axes(handles.x_view); imagesc(squeeze(handles.t1_matrix(handles.x,:,:)));
axes(handles.z_view); imagesc(squeeze(handles.t1_matrix(:,:,handles.z)));
guidata(hObject, handles);


% --- Executes on button press in change_z.
function change_z_Callback(hObject, eventdata, handles)
axes(handles.z_view); 
[y,x]=ginput(1);
handles.x=round(x); handles.y=round(y);
axes(handles.x_view); imagesc(squeeze(handles.t1_matrix(handles.x,:,:)));
axes(handles.y_view); imagesc(squeeze(handles.t1_matrix(:,handles.y,:)));
guidata(hObject, handles);


