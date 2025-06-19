ARG IMAGE_TAG=noble-torch2.5.1-jazzy
# FROM agarwalsaurav/pytorch_base:arm64-jammy-torch2.5.1-humble
# FROM agarwalsaurav/pytorch_base:arm64-noble-torch2.5.1-jazzy
# FROM agarwalsaurav/pytorch_base:noble-torch2.5.1-jazzy
FROM agarwalsaurav/pytorch_base:${IMAGE_TAG}
RUN apt-get -y update \
    && add-apt-repository universe \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && export LANG=en_US.UTF-8 \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && apt-get -y update \
    && apt-get -y upgrade \
    && apt install -y \
                  ros-${ROS_DISTRO}-rqt \
                  ros-${ROS_DISTRO}-rqt-action \
                  ros-${ROS_DISTRO}-rqt-bag \
                  ros-${ROS_DISTRO}-rqt-bag-plugins \
                  ros-${ROS_DISTRO}-rqt-common-plugins \
                  ros-${ROS_DISTRO}-rqt-console \
                  ros-${ROS_DISTRO}-rqt-controller-manager \
                  ros-${ROS_DISTRO}-rqt-dotgraph \
                  ros-${ROS_DISTRO}-rqt-graph \
                  ros-${ROS_DISTRO}-rqt-gui \
                  ros-${ROS_DISTRO}-rqt-gui-cpp \
                  ros-${ROS_DISTRO}-rqt-gui-py \
                  ros-${ROS_DISTRO}-rqt-image-overlay \
                  ros-${ROS_DISTRO}-rqt-image-overlay-layer \
                  ros-${ROS_DISTRO}-rqt-image-view \
                  ros-${ROS_DISTRO}-rqt-msg \
                  ros-${ROS_DISTRO}-rqt-plot \
                  ros-${ROS_DISTRO}-rqt-publisher \
                  ros-${ROS_DISTRO}-rqt-reconfigure \
                  ros-${ROS_DISTRO}-rqt-robot-dashboard \
                  ros-${ROS_DISTRO}-rqt-runtime-monitor \
                  ros-${ROS_DISTRO}-rqt-service-caller \
                  ros-${ROS_DISTRO}-rqt-tf-tree \
                  ros-${ROS_DISTRO}-rqt-topic \
    && apt-get -y autoremove \
    && apt-get -y clean autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -f /var/cache/apt/archives/*.deb \
    && rm -f /var/cache/apt/archives/parital/*.deb \
    && rm -f /var/cache/apt/*.bin

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

RUN echo "source /opt/ros/extra/install/local_setup.bash" >> /root/.bashrc
RUN echo "source /workspace/install/local_setup.bash" >> /root/.bashrc
RUN sed -i '/^export ROS_DOMAIN_ID/d' /root/.bashrc
