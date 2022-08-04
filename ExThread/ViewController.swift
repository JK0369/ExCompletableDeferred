//
//  ViewController.swift
//  ExThread
//
//  Created by Jake.K on 2022/08/04.
//

import UIKit

class ViewController: UIViewController {
  let completableDeferredSet = CompletableDeferredSet<Int>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Thread {
      self.completableDeferredSet.insert(1)
      self.completableDeferredSet.await()
      print("2.대기 종료!")
    }
    .start()
    
    DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
      print("1.작업 종료")
      self.completableDeferredSet.complete()
    }
  }
}

final class CompletableDeferredSet<T: Hashable> {
  private var workSet = Set<T>()
  private var canSignal = false
  private let semaphore = DispatchSemaphore(value: 0)
  
  func complete() {
    self.signalSemaphoreIfNeeded()
  }
  
  func insert(_ job: T) {
    self.signalSemaphoreIfNeeded()
    self.workSet.insert(job)
  }
  
  func remove(_ job: T) {
    self.signalSemaphoreIfNeeded()
    self.workSet.remove(job)
  }
  
  func await() {
    self.waitSemaphoreIfNeeded()
  }
  
  private func signalSemaphoreIfNeeded() {
    guard self.canSignal else { return }
    self.canSignal.toggle()
    self.semaphore.signal()
  }
  
  private func waitSemaphoreIfNeeded() {
    guard !self.canSignal else { return }
    self.canSignal.toggle()
    self.semaphore.wait()
  }
}

extension Thread {
  class func printCurrent() {
    print("\(Thread.current), isMainThread? = \(Thread.isMainThread)")
  }
}

/*
여기 동작?
1.작업 종료
<NSThread: 0x60000030a4c0>{number = 6, name = (null)}, isMainThread? = false
2.대기 종료!
*/
