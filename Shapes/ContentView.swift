//
//  ContentView.swift
//  Shapes
//
//  Created by Peter Hartnett on 8/2/22.
//
//This is an UI experiment app to setup programatic dice shapes for the use in another app, it's really just playing with modifier order, shape drawing and relative settings. Feel free to look at the code and implement anything you want in your own work.

import SwiftUI

struct ContentView: View {
    
    @State var frameSlide = 0.0
    var body: some View {
        VStack{
            VStack{
                //                ZStack{
                //                    Triangle()
                //                        .fill(.green)
                //                    Triangle()
                //                        .stroke(.black, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                //                }
                //                .frame(width: 100, height: 100, alignment: .bottom)
                //                Rectangle()
                //                    .stroke(.green, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                //                    .frame(width: 100, height: 100, alignment: .center)
                //                Hexagon()
                //                    .stroke(.red, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                //                    .frame(width: 100, height: 100, alignment: .center)
                ZStack{
                    Text("20")
                        .font(.system(size: 1000))
                        .scaledToFit()
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                        .frame(width: frameSlide*0.85, height: frameSlide*0.85, alignment: .center)
                    Polygon(corners: 6)
                        .fill(.tertiary)
                    //                        .frame(width: 100, height: 100, alignment: .center)
                    
                    Polygon(corners: 6)
                        .stroke(.tertiary, style: StrokeStyle(lineWidth: frameSlide * 0.05, lineCap: .round, lineJoin: .round))
                    //                        .frame(width: 100, height: 100, alignment: .center)
                }
                .frame(width: frameSlide, height: frameSlide, alignment: .center)
                //                .frame(width: 200, height: 200, alignment: .center)
                Spacer()
                Slider(value: $frameSlide, in: 4...500)
            }
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
        
        // figure out how much unused space we have at the bottom of our drawing rectangle
        let unusedSpace = (rect.height / 2 - bottomEdge) / 2
        
        // create and apply a transform that moves our path down by that amount, centering the shape vertically
        let transform = CGAffineTransform(translationX: center.x, y: center.y + unusedSpace)
        return path.applying(transform)
    }
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path{
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY*0.25))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY*0.75))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY*0.75))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY*0.25))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}


struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}
