import SwiftUI

struct TagLayout: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        guard let totalWidth = proposal.width else {
            return proposal.replacingUnspecifiedDimensions()
        }

        var origin = CGPoint.zero
        var vOffset = 0 as CGFloat
        var result = CGRect.zero

        for index in subviews.indices {
            let size = cache.sizes[index]

            let maxWidth = origin.x + size.width
            if maxWidth > totalWidth {
                origin.x = 0
                origin.y += vOffset
                result = result.union(CGRect(origin: origin, size: size))

                origin.x += size.width + cache.hSpacing[index]
                vOffset = 0
            } else {
                result = result.union(CGRect(origin: origin, size: size))

                origin.x += size.width + cache.hSpacing[index]
                vOffset = max(vOffset, size.height + cache.vSpacing[index])
            }
        }
        return result.size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        var origin = bounds.origin
        var vOffset = 0 as CGFloat

        for index in subviews.indices {
            let subview = subviews[index]
            let size = cache.sizes[index]

            let maxWidth = origin.x + size.width
            if maxWidth > bounds.maxX {
                origin.x = bounds.origin.x
                origin.y += vOffset
                subview.place(at: origin, proposal: .unspecified)

                origin.x += size.width + cache.hSpacing[index]
                vOffset = 0
            } else {
                subview.place(at: origin, proposal: .unspecified)

                origin.x += size.width + cache.hSpacing[index]
                vOffset = max(vOffset, size.height + cache.vSpacing[index])
            }
        }
    }

    func makeCache(subviews: Subviews) -> Cache {
        Cache(subviews: subviews)
    }

    struct Cache {
        let vSpacing: [CGFloat]
        let hSpacing: [CGFloat]
        let sizes: [CGSize]

        init(subviews: Subviews) {
            var vSpacing: [CGFloat] = []
            var hSpacing: [CGFloat] = []
            var sizes: [CGSize] = []

            for index in subviews.indices {
                let subview = subviews[index]

                sizes.append(subview.sizeThatFits(.unspecified))

                let spacing = subview.spacing
                if subviews.indices.contains(index + 1) {
                    let next = subviews[index + 1].spacing
                    vSpacing.append(spacing.distance(to: next, along: .vertical))
                    hSpacing.append(spacing.distance(to: next, along: .horizontal))
                } else {
                    vSpacing.append(0)
                    hSpacing.append(0)
                }
            }
            self.vSpacing = vSpacing
            self.hSpacing = hSpacing
            self.sizes = sizes
        }
    }
}
