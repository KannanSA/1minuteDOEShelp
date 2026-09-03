import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: WellbeingStore

    var body: some View {
        ZStack {
            SageTheme.cream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    feelCheck
                    careRow
                    weekly
                    kindNote
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("iFat")
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(SageTheme.ink)
                Text("A gentle check-in. Nothing to earn.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(SageTheme.muted)
            }
            Spacer()
            CareRingView(completed: store.careCount, total: store.careTotal)
        }
    }

    private var feelCheck: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How do you feel?")
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(SageTheme.ink)

            HStack(spacing: 10) {
                ForEach(Feeling.allCases) { feeling in
                    Button {
                        store.choose(feeling)
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: feeling.symbol)
                                .font(.system(size: 22))
                            Text(feeling.rawValue)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(store.today.feeling == feeling ? SageTheme.sage : SageTheme.paper)
                        )
                        .foregroundStyle(store.today.feeling == feeling ? SageTheme.cream : SageTheme.ink)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(SageTheme.sage.opacity(0.25), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("feeling-\(feeling.rawValue)")
                }
            }

            if let feeling = store.today.feeling {
                Text(feeling.note)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(SageTheme.sageDeep)
            }
        }
    }

    private var careRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today’s care")
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(SageTheme.ink)

            ForEach(CareAct.allCases) { act in
                Button {
                    store.toggle(act)
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: act.symbol)
                            .frame(width: 28)
                        Text(act.rawValue)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                        Spacer()
                        Image(systemName: store.today.completed.contains(act) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(store.today.completed.contains(act) ? SageTheme.sage : SageTheme.muted)
                    }
                    .foregroundStyle(SageTheme.ink)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(SageTheme.paper)
                    )
                }
                .buttonStyle(.plain)
                .disabled(act == .feel)
            }
        }
    }

    private var weekly: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This week")
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(SageTheme.ink)

            HStack {
                ForEach(Array(store.lastSevenDays().enumerated()), id: \.offset) { _, day in
                    VStack(spacing: 8) {
                        Circle()
                            .fill(dotColor(day.doneCount))
                            .frame(width: 16, height: 16)
                        Text(day.label)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(SageTheme.muted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(SageTheme.paper)
            )
        }
    }

    private var kindNote: some View {
        Text("No calorie counts. No body scores. Care is enough.")
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundStyle(SageTheme.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }

    private func dotColor(_ count: Int) -> Color {
        if count >= 3 { return SageTheme.sageDeep }
        if count >= 1 { return SageTheme.sage }
        return SageTheme.ringTrack
    }
}

#Preview {
    HomeView()
        .environmentObject(WellbeingStore())
}
