import Foundation

//
protocol AppStateService: class {
    var onAppEnterForeground: VoidClosure { get set }
}


