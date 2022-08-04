//
//  ContentView.swift
//  Shapes
//
//  Created by Peter Hartnett on 8/2/22.
//
//This is an UI experiment app to setup programatic dice shapes for the use in another app, it's really just playing with modifier order, shape drawing and relative settings. Feel free to look at the code and implement anything you want in your own work.
//NOTES:
//1) Text() size clearly has break points where it jumps up a step, in between those break points the text will slightly shift up and down
//2) Size scales need a little fiddling with, there is a switch statement for diff sized dice
//3) The number 4 sucks, its like the kerning for it is bad or something, it looks offset to the right and down. I do not know if this is worth bothering with.

import SwiftUI



struct ContentView: View {
    
    @State var frameSize = 100.0
    @State var sides = 3
    @State var textFrameMultiplier = 0.45
    
    var body: some View {
        VStack{
            VStack{
                
                ZStack{
                    Text("6")
                    //Setting the font to a very large size and then scaling it down to fit the container frame
                        .font(.system(size: 1000))
                        .scaledToFit()
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                        .frame(width: frameSize*textFrameMultiplier, height: frameSize*textFrameMultiplier, alignment: .center)
                    Polygon(corners: sides)
                        .fill(.tertiary)
                    Polygon(corners: sides)
                        .stroke(.tertiary, style: StrokeStyle(lineWidth: frameSize * 0.05, lineCap: .round, lineJoin: .round))
                }
                .frame(width: frameSize, height: frameSize, alignment: .center)
                Spacer()
                DieView(sides: sides, rollResult: String(40))
                    .foregroundColor(.red)
                
                VStack{
                    HStack{
                        Text("Size \(frameSize)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    Slider(value: $frameSize, in: 4...400)
                }
                Stepper("Sides \(sides)", value: $sides, in: 2...100, step: 1)
                VStack{
                    HStack{
                        Text("Text size \(textFrameMultiplier)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    Slider(value: $textFrameMultiplier, in: 0...1)
                }
            }
        }
        
        
    }
}


/// Creates an orthographic projection of a real die or a polygon if there is no real world example
struct DieView: View{
    var sides: Int
    var dieShape : Int {
        switch sides{
        case 2 : return 20
        case 4 : return 3
        case 6 : return 4
        case 8 : return 6
        case 10 : return 6
        case 12 : return 10
        case 20 : return 6
        case 100 : return 15
            //TODO: I do not really care for this default, it conflicts with the idea of showing the orthogonal view of a die as many odd sided die just don't exist. Of course they could in the idea of a log style die.
        default : return sides
        }
    }
    //We are taking the result as a string to allow for the use of emoji as die faces.
    var rollResult: String
    var textFrameMultiplier : Double {
        switch dieShape{
        case 3 : return 0.42
        case 4 : return 1
        case 5 : return 0.65
        default: return 0.70
            
        }
    }
    
    var body: some View{
        GeometryReader { geo in
            
            ZStack{
                Text("\(rollResult)")
                //Setting the font to a very large size and then scaling it down to fit the container frame
                    .font(.system(size: 1000))
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    .frame(width: min(geo.size.width, geo.size.height) * textFrameMultiplier, height: min(geo.size.width, geo.size.height) * textFrameMultiplier, alignment: .center)
                if dieShape == 4 {
                    
                    Rectangle()
                        .fill(.tertiary)
                    Rectangle()
                        .stroke(.tertiary, style: StrokeStyle(lineWidth: min(geo.size.width, geo.size.height) * 0.05, lineCap: .round, lineJoin: .round))
                    
                } else {
                    
                    Polygon(corners: dieShape)
                        .fill(.tertiary)
                    Polygon(corners: dieShape)
                        .stroke(.tertiary, style: StrokeStyle(lineWidth: min(geo.size.width, geo.size.height) * 0.05, lineCap: .round, lineJoin: .round))
                }
            }
            
            .frame(width: min(geo.size.width, geo.size.height) , height: min(geo.size.width, geo.size.height), alignment: .center)
            
        }
    }
}



struct Polygon: Shape {
    // store how many corners/sides the polygon has
    let corners: Int
    
    func path(in rect: CGRect) -> Path {
        // ensure we have at least two corners, otherwise send back an empty path
        guard corners >= 2 else { return Path() }
        
        // draw from the center of our rectangle
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        
        // start from directly upwards (as opposed to down or to the right)
        var currentAngle = -CGFloat.pi / 2
        let startAngle = currentAngle
        
        // calculate how much we need to move with each star corner
        let angleAdjustment = .pi * 2 / Double(corners * 2)
        
        // we're ready to start with our path now
        var path = Path()
        
        // move to our initial position
        path.move(to: CGPoint(x: center.x * cos(currentAngle), y: center.y * sin(currentAngle)))
        
        // track the lowest point we draw to, so we can center later
        var bottomEdge: Double = 0
        
        // loop over all our points/inner points
        for _ in 0..<corners  {
            // figure out the location of this point
            let sinAngle = sin(currentAngle)
            let cosAngle = cos(currentAngle)
            let bottom: Double
            
            // store this Y position
            bottom = center.y * sinAngle
            
            // …and add a line to there
            path.addLine(to: CGPoint(x: center.x * cosAngle, y: bottom))
            
            // if this new bottom point is our lowest, stash it away for later
            if bottom > bottomEdge {
                bottomEdge = bottom
            }
            // move on to the next corner
            currentAngle += angleAdjustment * 2
        }
        
        //close the shape
        path.addLine(to: CGPoint(x: center.x * cos(startAngle), y: center.y * sin(startAngle)))
        
        // create and apply a transform that moves our path down by that amount, centering the shape vertically
        let transform = CGAffineTransform(translationX: center.x, y: center.y)
        return path.applying(transform)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}
