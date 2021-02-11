//
//  ContentView.swift
//  Assignment One
//

import SwiftUI

struct TeamBiosView: View {
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
            Image("MichaelCooper").resizable()
                .frame(width: 180, height: 180).clipShape(Circle()).shadow(radius: 10)
            Text("Michael Cooper").font(.title).bold().underline()
            Divider()
            Text("I'm Michael, a M.S. Computer Science (AI Track) student from Victoria, Canada. My academic and research interests are centered around applying machine learning to problems in the medical space: specifically, I am excited about building robust few-shot and interpretable model architectures for medical image analysis. In my free time, I enjoy social dancing, skiing, paintballing, and running. I'm also always looking for good book recommendations, so don't feel shy about sharing your favourite titles with me!").font(.system(size: 13)).padding()
            Divider()
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 35, content: {
                Link(destination: URL(string: "https://linkedin.com/in/coopermj/")!, label: {
                    Text("")
                    Image("linkedin")
                        .resizable()
                        .frame(width: 30, height: 30).shadow(radius: 10)
                })
                Link(destination: URL(string: "https://github.com/cooper-mj")!, label: {
                    Text("")
                    Image("github")
                        .resizable()
                        .frame(width: 30, height: 30).shadow(radius: 10)
                })
                Link(destination: URL(string: "https://michaeljohncooper.com")!, label: {
                    Text("")
                    Image("personalsite")
                        .resizable()
                        .frame(width: 30, height: 30).shadow(radius: 10)
                })
            }).padding()
            
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TeamBiosView()
    }
}
