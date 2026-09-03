#!/usr/bin/env bash
# ==============================================================================
# KathaQuest - Flutter Setup & Execution Helper for Fedora Linux
# ==============================================================================
set -e

echo "🌟 Welcome to KathaQuest Flutter Setup!"
echo "----------------------------------------"

# 1. Check if Flutter is already installed
if command -v flutter &> /dev/null; then
    echo "✅ Flutter SDK found in PATH: $(flutter --version | head -n 1)"
else
    echo "🔍 Flutter not found in PATH. Checking common install paths..."
    
    FLUTTER_CANDIDATE="$HOME/development/flutter/bin"
    if [ -d "$FLUTTER_CANDIDATE" ]; then
        export PATH="$FLUTTER_CANDIDATE:$PATH"
        echo "✅ Found Flutter at $FLUTTER_CANDIDATE and added to temporary PATH."
    else
        echo "📥 Flutter SDK is not installed yet."
        echo ""
        echo "To install Flutter on Fedora Linux:"
        echo "1) Run the following commands:"
        echo "   mkdir -p ~/development"
        echo "   cd ~/development"
        echo "   git clone https://github.com/flutter/flutter.git -b stable"
        echo ""
        echo "2) Add Flutter to your ~/.bashrc:"
        echo "   echo 'export PATH=\"\$HOME/development/flutter/bin:\$PATH\"' >> ~/.bashrc"
        echo "   source ~/.bashrc"
        echo ""
        echo "3) Install Linux desktop build prerequisites (if running native desktop):"
        echo "   sudo dnf install -y clang cmake ninja-build gtk3-devel"
        echo ""
        echo "Alternatively, you can run KathaQuest instantly in your browser via Flutter Web:"
        echo "   flutter run -d chrome"
        exit 0
    fi
fi

# 2. Get dependencies
echo "📦 Resolving project dependencies..."
flutter pub get

# 3. Run automated tests
echo "🧪 Running KathaQuest automated test suite..."
flutter test

echo ""
echo "🚀 Everything is ready! To launch KathaQuest, run:"
echo "   flutter run -d chrome   # (Recommended for low-spec laptops: Instant Web app!)"
echo "   flutter run -d linux    # (Native Linux desktop app)"
