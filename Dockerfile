ARG IMAGE_TAG=noble-torch2.5.1-jazzy
# FROM agarwalsaurav/pytorch_base:arm64-jammy-torch2.5.1-humble
# FROM agarwalsaurav/pytorch_base:arm64-noble-torch2.5.1-jazzy
# FROM agarwalsaurav/pytorch_base:noble-torch2.5.1-jazzy
FROM agarwalsaurav/pytorch_base:${IMAGE_TAG}
RUN apt install -y \
    ros-jazzy-rqt \
    ros-jazzy-rqt-action \
    ros-jazzy-rqt-bag \
    ros-jazzy-rqt-bag-plugins \
    ros-jazzy-rqt-common-plugins \
    ros-jazzy-rqt-console \
    ros-jazzy-rqt-controller-manager \
    ros-jazzy-rqt-dotgraph \
    ros-jazzy-rqt-graph \
    ros-jazzy-rqt-gui \
    ros-jazzy-rqt-gui-cpp \
    ros-jazzy-rqt-gui-py \
    ros-jazzy-rqt-image-overlay \
    ros-jazzy-rqt-image-overlay-layer \
    ros-jazzy-rqt-image-view \
    ros-jazzy-rqt-msg \
    ros-jazzy-rqt-plot \
    ros-jazzy-rqt-publisher \
    ros-jazzy-rqt-reconfigure \
    ros-jazzy-rqt-robot-dashboard \
    ros-jazzy-rqt-runtime-monitor \
    ros-jazzy-rqt-service-caller \
    ros-jazzy-rqt-tf-tree \
    ros-jazzy-rqt-topic

RUN git clone -b release/1.14 https://github.com/PX4/px4_msgs.git /opt/ros/extra/src/px4_msgs
WORKDIR /opt/ros/extra/
# RUN . /opt/ros/humble/setup.sh && colcon build --packages-select px4_msgs
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && colcon build --packages-select px4_msgs

COPY install_dependencies.sh /opt/install_dependencies.sh
RUN chmod +x /opt/install_dependencies.sh
RUN ["/bin/bash", "-c", "/opt/install_dependencies.sh --geographiclib"]

COPY CoverageControl.zip /opt/CoverageControl.zip
RUN unzip /opt/CoverageControl.zip -d /opt/; \
    rm /opt/CoverageControl.zip
WORKDIR /opt/CoverageControl-dev
RUN bash setup.sh
RUN /opt/venv/bin/pip install .

RUN git clone https://github.com/pac-ws/geolocaltransform.git /opt/px4_ws/src/geolocaltransform
WORKDIR /opt/px4_ws/src/geolocaltransform
RUN /opt/venv/bin/pip install .

RUN /opt/venv/bin/pip uninstall -y setuptools_scm

# Remove cache to reduce image size
RUN rm -rf /var/lib/apt/lists/*; \
		rm -f /var/cache/apt/archives/*.deb; \
		rm -f /var/cache/apt/archives/parital/*.deb; \
		rm -f /var/cache/apt/*.bin

WORKDIR /root

RUN echo "export ROS_DOMAIN_ID=10" >> /root/.bashrc
RUN echo "source /opt/ros/extra/install/local_setup.bash" >> /root/.bashrc
RUN echo "source /workspace/install/local_setup.bash" >> /root/.bashrc
