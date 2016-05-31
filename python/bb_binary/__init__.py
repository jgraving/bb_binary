
import capnp
import os
import numpy as np

capnp.remove_import_hook()

_dirname = os.path.dirname(os.path.realpath(__file__))
bbb = capnp.load(os.path.join(_dirname, 'bb_binary_schema.capnp'))
Frame = bbb.Frame
FrameContainer = bbb.FrameContainer
DataSource = bbb.DataSource
Cam = bbb.Cam
DetectionCVP = bbb.DetectionCVP
DetectionDP = bbb.DetectionDP


def convert_detections_to_numpy(frame):
    """
    Returns the detections as a numpy array from the frame.
    """

    union_type = frame.detectionsUnion.which()
    assert union_type == 'detectionsDP', \
        "Currently only the new pipeline format is supported."
    detections = frame.detectionsUnion.detectionsDP

    shape = (len(detections), nb_parameters(detections[0]))
    arr = np.zeros(shape, dtype=np.float32)
    for i, detection in enumerate(detections):
        arr[i, 0] = detection.tagIdx
        arr[i, 1] = detection.xpos
        arr[i, 2] = detection.ypos
        arr[i, 3] = detection.zRotation
        arr[i, 4] = detection.yRotation
        arr[i, 5] = detection.xRotation
        arr[i, 6] = detection.radius
        arr[i, 7:] = np.array(list(detection.decodedId)) / 255

    return arr


def nb_parameters(detection):
    """Returns the number of parameter of the detections."""
    return 7 + len(detection.decodedId)


def build_frame(
        frame_builder,
        timestamp,
        detections,
        detection_format='deeppipeline'
):
    """
    Builds a frame from a numpy array.
    Usage (not tested):
    ```
    frames = [(timestamp, pipeline(image_to_timestamp))]
    nb_frames = len(frames)
    fc = FrameContainer.new_message()
    frames_builder = fc.init('frames', len(frames))
    for i, (timestamp, detections) in enumerate(frames):
        build_frame(frame_builder[i], timestamp, detections)
    ```
    """
    assert detection_format == 'deeppipeline'
    detec_builder = frame_builder.detectionsUnion.init('detectionsDP',
                                                       len(detections))
    for i, detection in enumerate(detections):
        detec_builder[i].tagIdx = int(detection[0])
        detec_builder[i].xpos = int(detection[1])
        detec_builder[i].ypos = int(detection[2])
        detec_builder[i].zRotation = float(detection[3])
        detec_builder[i].yRotation = float(detection[4])
        detec_builder[i].xRotation = float(detection[5])
        detec_builder[i].radius = float(detection[6])
        decodedId = detec_builder[i].init('decodedId', len(detection) - 7)
        for j, bit in enumerate(detections[i, 7:]):
            decodedId[j] = int(round(255*bit))


class Repository:
    """
    The Repository class manages multiple bb_binary files. It creates a
    directory layout that enables fast access by the timestamp.
    """
    def __init__(self, root_dir):
        """
        Opens the repository at `root_dir`
        """
        self.root_dir = root_dir

    def add(frame_container: bbb.FrameContainer):
        """
        Adds the `frame_container` to the repository.
        """
        pass

    def load(timestamp, cam) -> bbb.FrameContainer:
        """
        Finds and load the FrameContainer that matches the timestamp and the
        cam.
        """
        pass

    def find(timestamp) -> 'list(str)':
        """
        Returns all files that includes detections to the timestamp
        """
        pass

    @staticmethod
    def init(path, split_strategy):
        """
        Creates a new blank repository
        """
        pass
