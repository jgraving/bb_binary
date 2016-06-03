@0xa7d4a096084cee0e;

using Java = import "java.capnp";
$Java.package("de.fuberlin.biorobotics");
$Java.outerClassname("BeesBook");


struct DetectionCVP {
  tagIdx @0 :UInt16;             # unique sequential id of the tag
  candidateIdx @1 :UInt16;       # sequential id of the candidate per tag
  gridIdx @2 :UInt16;            # sequential id of the grid/decoding per candidate
  xpos @3 :UInt16;               # x coordinate of the grid center
  ypos @4 :UInt16;               # y coordinate of the grid center
  xposHive @5 :UInt16;           # x coordinate of the grid center wrt. the hive
  yposHive @6 :UInt16;           # y coordinate of the grid center wrt. the hive
  hiveId @7 :UInt8;              # the id of the hive
  zRotation @8 :Float32;         # rotation of the grid in x plane
  yRotation @9 :Float32;         # rotation of the grid in y plane
  xRotation @10 :Float32;        # rotation of the grid in z plane
  lScore @11 :Float32;           # roi score (Localizer)
  eScore @12 :UInt16;            # ellipse score (EllipseFitter)
  gScore @13 :Float32;           # grid score (GridFitter)
  decodedId @14 :UInt32;         # decoded id
}

struct DetectionDP {
  tagIdx @0 :UInt16;             # unique idx of the detection
  xpos @1 :UInt16;               # x coordinate of the grid center wrt. the image
  ypos @2 :UInt16;               # y coordinate of the grid center wrt. the image
  xposHive @3 :UInt16;           # x coordinate of the grid center wrt. the hive
  yposHive @4 :UInt16;           # y coordinate of the grid center wrt. the hive
  hiveId @5 :UInt8;              # the id of the hive
  zRotation @6 :Float32;         # rotation of the grid in x plane
  yRotation @7 :Float32;         # rotation of the grid in y plane
  xRotation @8 :Float32;         # rotation of the grid in z plane
  radius @9 :Float32;            # radius of the tag
  localizerSaliency @10 :Float32;# saliency of the localizer network
  decodedId @11 :List(UInt8);    # the decoded id, the bit probabilities are discretised to 0-255
}


# Corresponds to an image in the video
struct Frame {
  id @0 :UInt64;                # unique id of the frame
  timestamp @1 :UInt64;         # unix time stamp of the frame
  detectionsUnion : union {
    detectionsCVP @2 :List(DetectionCVP);     # detections format of the old computer vision pipeline
    detectionsDP  @3 :List(DetectionDP);      # detections format of the new deeppipeline
  }
}


struct Cam {
    camId @0 :UInt16;               # the cam number
    rotation @1 :Float32;           # the cam is rotated by this angle (in radians)
}

struct DataSource {
    filename @0 :Text;               # filename of the data source
    videoPreviewFilename @1 :Text;   # (optional) filename of the preview video
    videoFirstFrameIdx @2 :UInt32;   # the start frame of the video. Not set if the data source is not a video
    videoLastFrameIdx @3 :UInt32;    # the end frame of the video. Not set if the data source is not a video
    frameIds @4 :List(UInt64);       # the id's of the frames from this data source. Contains only one id if the data source is an image.
    cam @5 :Cam;                     # the cam
}

# Corresponds to a video
struct FrameContainer {
  id @0 :UInt64;                    # global unique id of the frame container
  dataSources @1: List(DataSource);
                                    # if we operate on stitched images, we can have multiple data source for one frame.
                                    # the outer list is over the different cameras and the inner list is over the different
                                    # videos / images from the cams.
  fromTimestamp @2 :UInt64;         # timestamp of the first frame
  toTimestamp @3 :UInt64;           # timestamp of the last frame
  frames @4 :List(Frame);           # frames are sorted by the timestamp in ascending order
}