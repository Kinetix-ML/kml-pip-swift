// The Swift Programming Language
// https://docs.swift.org/swift-book
import UIKit
/// An enum describing a body part (e.g. nose, left eye etc.).
public enum BodyPart: String, CaseIterable, Decodable, Encodable {
    case nose = "nose"
    case leftEye = "left eye"
    case rightEye = "right eye"
    case leftEar = "left ear"
    case rightEar = "right ear"
    case leftShoulder = "left shoulder"
    case rightShoulder = "right shoulder"
    case leftElbow = "left elbow"
    case rightElbow = "right elbow"
    case leftWrist = "left wrist"
    case rightWrist = "right wrist"
    case leftHip = "left hip"
    case rightHip = "right hip"
    case leftKnee = "left knee"
    case rightKnee = "right knee"
    case leftAnkle = "left ankle"
    case rightAnkle = "right ankle"
    
    /// Get the index of the body part in the array returned by pose estimation models.
    public var position: Int {
        return BodyPart.allCases.firstIndex(of: self) ?? 0
    }
}

public enum MLKitBodyPart: String, CaseIterable, Decodable, Encodable {
    case nose = "nose"
    case leftEyeInner = "left eye inner"
    case leftEye = "left eye"
    case leftEyeOuter = "left eye outer"
    case rightEyeInner = "right eye inner"
    case rightEye = "right eye"
    case rightEyeOuter = "right eye outer"
    case leftEar = "left ear"
    case rightEar = "right ear"
    case leftMouth = "left mouth"
    case rightMouth = "right mouth"
    case leftShoulder = "left shoulder"
    case rightShoulder = "right shoulder"
    case leftElbow = "left elbow"
    case rightElbow = "right elbow"
    case leftWrist = "left wrist"
    case rightWrist = "right wrist"
    case leftPinky = "left pinky"
    case rightPinky = "right pinky"
    case leftIndex = "left index"
    case rightIndex = "right index"
    case leftThumb = "left thumb"
    case rightThumb = "right thumb"
    case leftHip = "left hip"
    case rightHip = "right hip"
    case leftKnee = "left knee"
    case rightKnee = "right knee"
    case leftAnkle = "left ankle"
    case rightAnkle = "right ankle"
    case leftHeel = "left heel"
    case rightHeel = "right heel"
    case leftFootIndex = "left foot index"
    case rightFootIndex = "right foot index"
    
    /// Get the index of the body part in the array returned by pose estimation models.
    public var position: Int {
        return MLKitBodyPart.allCases.firstIndex(of: self) ?? 0
    }
}


public class KeyPoint: Decodable, Encodable {
    public var bodyPart: BodyPart = .nose
    public var coordinate: CGPoint = .zero
    public var score: Float32 = 0.0
    
    public init(bodyPart: BodyPart, coordinate: CGPoint, score: Float32) {
        self.bodyPart = bodyPart
        self.coordinate = coordinate
        self.score = score
    }
    
    public init(bodyPart: BodyPart, coordinate: CGPoint) {
        self.bodyPart = bodyPart
        self.coordinate = coordinate
    }
    public init(coordinate: CGPoint) {
        self.coordinate = coordinate
    }
    
    public func within(xBounds: (CGFloat, CGFloat), yBounds: (CGFloat, CGFloat)) -> Bool {
        return self.coordinate.x > xBounds.0 && self.coordinate.x < xBounds.1 && self.coordinate.y > yBounds.0 && self.coordinate.y < yBounds.1
    }
}

public class KeyPoint3D: KeyPoint {
    public var distance: CGFloat
    public init (bodyPart: BodyPart, coordinate: CGPoint, distance: CGFloat, score: Float32) {
        self.distance = distance
        super.init(bodyPart: bodyPart, coordinate: coordinate, score: score)
    }
    public init (bodyPart: BodyPart, coordinate: CGPoint, distance: CGFloat) {
        self.distance = distance
        super.init(bodyPart: bodyPart, coordinate: coordinate)
    }
    public init (coordinate: CGPoint, distance: CGFloat) {
        self.distance = distance
        super.init(coordinate: coordinate)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

public class KPFrame: Decodable, Encodable {
    public var keyPoints: [KeyPoint]
    public var score: Float32
    
    public init(keyPoints: [KeyPoint], score: Float32) {
        self.keyPoints = keyPoints
        self.score = score
    }
}

// MARK: Detection result
/// Time required to run pose estimation on one frame.
public struct Times {
    public var preprocessing: TimeInterval
    public var inference: TimeInterval
    public var postprocessing: TimeInterval
    public var total: TimeInterval { preprocessing + inference + postprocessing }
    public init(preprocessing: TimeInterval, inference: TimeInterval, postprocessing: TimeInterval) {
        self.preprocessing = preprocessing
        self.inference = inference
        self.postprocessing = postprocessing
    }
}
/// A person detected by a pose estimation model.
public struct Person {
    public var keyPoints: [KeyPoint]
    public var score: Float32
    public init(keyPoints: [KeyPoint], score: Float32) {
        self.keyPoints = keyPoints
        self.score = score
    }
}
