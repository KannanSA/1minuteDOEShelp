import SwiftUI

struct WorkoutSessionView: View {
    @EnvironmentObject private var store: GymStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            GymTheme.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text("PUSH")
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(GymTheme.white)

                Text("Check lifts as you finish them.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(GymTheme.mute)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(store.todayLifts) { lift in
                            Button {
                                store.toggleLift(lift)
                            } label: {
                                HStack {
                                    Image(systemName: store.checkedLiftIDs.contains(lift.id) ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(store.checkedLiftIDs.contains(lift.id) ? GymTheme.volt : GymTheme.mute)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(lift.name.uppercased())
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(GymTheme.white)
                                        Text(lift.scheme)
                                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                                            .foregroundStyle(GymTheme.mute)
                                    }
                                    Spacer()
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(GymTheme.raised)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Button {
                    store.finishWorkout()
                    dismiss()
                } label: {
                    Text("Finish workout")
                        .font(.system(size: 18, weight: .heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Capsule().fill(GymTheme.volt))
                        .foregroundStyle(Color.black)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(GymTheme.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
