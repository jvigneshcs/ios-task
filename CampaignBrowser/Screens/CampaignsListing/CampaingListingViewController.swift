import UIKit
import RxSwift


/**
 The view controller responsible for listing all the campaigns. The corresponding view is the `CampaignListingView` and
 is configured in the storyboard (Main.storyboard).
 */
class CampaignListingViewController: UIViewController {

    private let disposeBag = DisposeBag()

    private let imageService = ServiceLocator.instance.imageService
    
    private let campaignFlowLayout: CampaignFlowLayout = {
        let flowLayout = CampaignFlowLayout()
        flowLayout.sectionInsetReference = .fromContentInset // .fromContentInset is default
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = .zero
        
        return flowLayout
    }()
    
    @available (iOS 13.0, *)
    private var compositionalLayout: UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: NSCollectionLayoutDimension.estimated(450)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size,
                                                       subitem: item,
                                                       count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        section.interGroupSpacing = 0
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    @IBOutlet
    private(set) weak var typedView: CampaignListingView!

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(typedView != nil)
        if #available(iOS 14.0, *) {
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.showsSeparators = false
            self.typedView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: config)
        } else if #available(iOS 13.0, *) {
            self.typedView.collectionViewLayout = self.compositionalLayout
        } else {
            self.typedView.collectionViewLayout = self.campaignFlowLayout
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Load the campaign list and display it as soon as it is available.
        ServiceLocator.instance.networkingService
            .createObservableResponse(request: CampaignListingRequest())
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] campaigns in
                guard let self = self else { return }
                self.typedView.display(campaigns: campaigns.map {
                    CampaignListingView.Campaign(
                        name: $0.name,
                        description: $0.description,
                        moodImage: self.imageService.getImage(url: $0.moodImage)
                    )
                })
            })
            .disposed(by: disposeBag)
    }
}
