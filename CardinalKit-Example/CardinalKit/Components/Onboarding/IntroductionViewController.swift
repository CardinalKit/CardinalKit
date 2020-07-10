//
//  IntroductionViewController.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import UIKit

/**
  Enables a "swipe-able" interfaces for the three intro view controllers
  on our `Main` storyboard file.
  
  Relies on having a `Main.storyboard` file with three VC identifiers:
  `introOneViewController`,
  `introTwoViewController`,
   and `introThreeViewController`
 */
class IntroductionViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    // MARK: Properties
    let pageViewControllers: [UIViewController] = {
        let introOne = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "introOneViewController")
        let introTwo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "introTwoViewController")
        let introThree = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "introThreeViewController")
        
        return [introOne, introTwo, introThree]
    }()
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        dataSource = self
        
        setViewControllers([pageViewControllers[0]], direction: .forward, animated: false, completion: nil)
        
        let pageControl: UIPageControl = UIPageControl.appearance(whenContainedInInstancesOf: [IntroductionViewController.self])
        pageControl.pageIndicatorTintColor = UIColor.altoGrey
        pageControl.currentPageIndicatorTintColor = UIColor.radicalRed
    }
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = pageViewControllers.firstIndex(of: viewController)!
        
        if index - 1 >= 0 {
            return pageViewControllers[index - 1]
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = pageViewControllers.firstIndex(of: viewController)!
        
        if index + 1 < pageViewControllers.count {
            return pageViewControllers[index + 1]
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
