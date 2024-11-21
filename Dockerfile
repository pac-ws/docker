FROM agarwalsaurav/pytorch_base:arm64-jammy-torch2.5.1-humble
# FROM agarwalsaurav/pytorch_base:jammy-torch2.4.1-humble
RUN git clone -b release/1.14 https://github.com/PX4/px4_msgs.git /opt/ros/extra/src/px4_msgs
WORKDIR /opt/ros/extra/
RUN . /opt/ros/humble/setup.sh && colcon build --packages-select px4_msgs

COPY install_dependencies.sh /opt/install_dependencies.sh
RUN chmod +x /opt/install_dependencies.sh
RUN ["/bin/bash", "-c", "/opt/install_dependencies.sh --geographiclib"]

COPY CoverageControl.tar.xz /opt/CoverageControl.tar.xz
RUN tar -xvf /opt/CoverageControl.tar.xz -C /opt/; \
    rm /opt/CoverageControl.tar.xz
WORKDIR /opt/CoverageControl
RUN bash setup.sh
RUN /opt/venv/bin/pip install .
RUN /opt/venv/bin/pip install scipy

COPY GeoLocalTransform /opt/GeoLocalTransform
WORKDIR /opt/GeoLocalTransform
RUN /opt/venv/bin/pip install .

RUN /opt/venv/bin/pip uninstall -y setuptools_scm
RUN apt-get update && apt-get install -y neovim

# Remove cache to reduce image size
RUN rm -rf /var/lib/apt/lists/*; \
		rm -f /var/cache/apt/archives/*.deb; \
		rm -f /var/cache/apt/archives/parital/*.deb; \
		rm -f /var/cache/apt/*.bin

RUN echo "export ROS_DOMAIN_ID=10" >> /root/.bashrc
RUN echo "source /opt/ros/extra/install/local_setup.bash" >> /root/.bashrc
RUN echo "source /workspace/install/local_setup.bash" >> /root/.bashrc
